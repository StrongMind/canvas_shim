User.class_eval do
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

  def recent_feedback(opts={})
    context_codes = opts[:context_codes]
    context_codes ||= if opts[:contexts]
                        setup_context_lookups(opts[:contexts])
                      else
                        self.participating_student_course_ids.map { |id| "course_#{id}" }
                      end
    filter_feedback(submissions_for_context_codes(context_codes, opts))
  end

  private

  def filter_feedback(submissions)
    submissions.select { |sub| sub.grader_id > 1 }
  end
end
