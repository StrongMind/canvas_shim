User.class_eval do
  def custom_placement_at(content_tag)
    context_module = content_tag.context_module
    course = context_module.context

    new_placement_position = content_tag.position - 1

    # bypass 'lower' module units
    bypass_modules = course.context_modules.where('position < ?', context_module.position).order(position: :asc)

    bypass_modules.each do |bypass_module|
      bypass_module.content_tags
                   .active
                   .order(position: :asc).each do |tag|

        bypass_requirement(tag)
      end
    end

    # bypass lower units in new placements context_module
    context_module.content_tags
                  .active
                  .where('position <= ?', new_placement_position)
                  .order(position: :asc).each do |tag|

      bypass_requirement(tag)
    end
  end

  def bypass_requirement(content_tag)
    context_module = content_tag.context_module

    requirement = context_module.completion_requirements.to_a.find do |req|
      req[:id] == content_tag.local_id
    end

    return if requirement.nil?

    action_needed = case requirement[:type]
                    when 'must_view'
                      :read
                    when 'must_mark_done'
                      :done
                    when 'must_contribute'
                      :contributed
                    when 'must_submit'
                      # exclude the assignment
                      content_tag.content.toggle_exclusion(self.id, true)
                      :submitted
                    when 'min_score'
                      # exclude the quiz? assignment
                      content_tag.content.assignment.toggle_exclusion(self.id, true)
                      :scored
                    else
                      raise 'Unknown requirement type'
                    end

    if requirement[:type] == 'min_score'
      # pass the score requirement by giving requirement check a 100
      content_tag.context_module_action(self, action_needed, 100)
    else
      content_tag.context_module_action(self, action_needed)
    end
  end

  def get_teacher_unread_discussion_topic_assignments(course)
    topic_microservice_endpoint = ENV['TOPIC_MICROSERVICE_ENDPOINT']
    api_key = ENV['TOPIC_MICROSERVICE_API_KEY']
    return {} unless topic_microservice_endpoint && api_key
    return {} if self.enrollments.where(type: 'TeacherEnrollment').empty?
    endpoint = "#{topic_microservice_endpoint}/teachers/#{ENV['CANVAS_DOMAIN']}:#{self.id}/topics/"
    ret = HTTParty.get(endpoint, headers: { "x-api-key": api_key })
    return {} unless ret.code == 200
    ids = JSON.parse(ret.body).map(&:to_i)

    Assignment.joins(:discussion_topic).where('discussion_topics.id' => ids).where('context_id' => course.id)
  end

  def recent_feedback_with_wrap(opts={})
    filter_feedback(recent_feedback_without_wrap(opts))
  end

  alias_method :recent_feedback_without_wrap, :recent_feedback
  alias_method :recent_feedback, :recent_feedback_with_wrap

  private

  def filter_feedback(submissions)
    submissions.select { |sub| sub.submission_comments.any? || (sub.grader_id && sub.grader_id > 1) }
  end
end
