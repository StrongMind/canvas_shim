DiscussionEntry.class_eval do
  alias_method :change_read_state_alias, :change_read_state
  after_create :send_new_discussion_alert, if: :is_discussion_reply_from_student?
  after_save :set_unread_status

  def set_unread_status
    topic_microservice_endpoint = ENV['TOPIC_MICROSERVICE_ENDPOINT']
    api_key                     = ENV['TOPIC_MICROSERVICE_API_KEY']

    return unless topic_microservice_endpoint && api_key
    return unless SettingsService.get_settings(object: 'school', id: 1)['show_unread_discussions']

    topic  = self.discussion_topic
    course = self.discussion_topic.course

    course.teachers.each do |teacher|
      endpoint = "#{topic_microservice_endpoint}/teachers/#{ENV['CANVAS_DOMAIN']}:#{teacher.id}/topics/#{topic.id}"

      if self.unread?(teacher)
        HTTParty.post(endpoint, headers: { "x-api-key": api_key })
      else
        HTTParty.delete(endpoint, headers: { "x-api-key": api_key })
      end
    end
  end

  def change_read_state(new_state, current_user = nil, opts = {})
    result = change_read_state_alias(new_state, current_user, opts)
    set_unread_status
    result
  end

  def send_new_discussion_alert
    assignment = discussion_topic.assignment
    return unless assignment

    teacher_ids_to_alert.each do |teacher_id|
      AlertsService::Client.create(
        :student_discussion_entry,
        teacher_id: teacher_id,
        student_id: user_id,
        assignment_id: assignment.id,
        course_id: assignment.course.id,
        message: message
      )
    end
  end

  private
  def is_discussion_reply_from_student?
    reply_alerts_on? && is_from_student? && (parent_id || !is_first_post?)
  end

  def is_from_student?
    user.student_enrollments.exists?(course: discussion_topic.course)
  end

  def reply_alerts_on?
    SettingsService.get_settings(object: :school, id: 1)['reply_alerts']
  end

  def teacher_ids_to_alert
    discussion_topic.course.teacher_enrollments.pluck(:user_id)
  end

  def is_first_post?
    self.discussion_topic.discussion_entries.where(user_id: user_id, parent_id: nil).count == 1
  end

end
