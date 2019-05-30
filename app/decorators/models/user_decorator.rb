User.class_eval do
  after_commit -> { PipelineService::V2.publish self }

  # Submissions must be excused upfront else once the first requirement check happens
  # the all_met condition will fail on submissions not being excused yet
  #
  # content_tag - where we want to place them
  # context_module - module of the place we want to place them
  def custom_placement_at(content_tag)
    context_module         = content_tag.context_module
    course                 = context_module.context
    new_placement_position = content_tag.position - 1

    # get 'lower' module units in Course
    bypass_modules = course.context_modules
                           .where('position < ?', context_module.position)
                           .order(position: :asc)

    # get 'lower' content tags within same context_module as where we're dropping user
    bypass_tags = context_module.content_tags
                  .active
                  .where('position <= ?', new_placement_position)
                  .order(position: :asc)

    # exclude any submissions requirements
    bypass_modules.each do |bypass_module|
      bypass_module.content_tags
                   .active
                   .order(position: :asc).each do |tag|

        exclude_submissions(tag)
      end
    end

    # exclude any submissions requirements
    bypass_tags.each do |tag|
      exclude_submissions(tag)
    end

    # force progression requirements of lower modules
    bypass_modules.each do |bypass_module|
      progression = bypass_module.find_or_create_progression(self) # self is user
      progression.update_columns requirements_met: bypass_module.completion_requirements,
                                 evaluated_at: (bypass_module.updated_at - 1.second),
                                 current: false # mark as outdated # TODO change back to false

      progression.reload.evaluate!
      sleep(Rails.env.production? ? 5 : 1)
    end

    # force progression requirements of lower tags in new placements context_module
    bypass_tags_context_module = context_module

    return if bypass_tags_context_module.nil?

    requirements_of_bypass_tags = bypass_tags.map do |tag|
      bypass_tags_context_module.completion_requirements.find do |req|
        req[:id] == tag.id
      end
    end.compact

    # puts '*** requirements_of_bypass_tags ***'
    # puts requirements_of_bypass_tags

    progression = bypass_tags_context_module.find_or_create_progression(self) # self is user
    progression.update_columns requirements_met: requirements_of_bypass_tags,
                               evaluated_at: (bypass_tags_context_module.updated_at - 1.second),
                               current: false # mark as outdated # TODO change back to false

    progression.reload.evaluate!

    AssignmentOverrideStudent.where(user_id: self.id, assignment_id: course.assignment_ids).each(&:destroy!) # run through each as we want callbacks to fire
    sleep(Rails.env.production? ? 5 : 1)
  end

  def exclude_submissions(tag)
    tag.context_module.completion_requirements.each do |req|
      next unless req[:id] == tag.id

      case req[:type]
      when 'must_submit'
        # exclude the assignment
        subs = tag&.content&.submissions&.where(user_id: self.id) || []
        subs.each do |sub|
          sub.update_column :excused, true
        end
      when 'min_score'
        # exclude the quiz? assignment
        # tag.content.assignment.toggle_exclusion(self.id, true)
        subs = tag&.content&.assignment&.submissions&.where(user_id: self.id) || []
        subs.each do |sub|
          sub.update_column :excused, true
        end
      end
    end
  end

  def get_teacher_unread_discussion_topics(course)
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
