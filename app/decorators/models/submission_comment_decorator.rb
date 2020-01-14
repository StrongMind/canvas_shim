SubmissionComment.class_eval do
  after_commit :send_feedback_alert, if: :is_submission_comment_from_student?

  def is_submission_comment_from_student?
    return unless reply_alerts_on? && context.is_a?(Course)
    !teacher_ids.include?(author_id)
  end

  def send_feedback_alert
    teacher_ids.each do |teacher_id|
      AlertsService::Client.create(
        :student_feedback,
        teacher_id: teacher_id,
        student_id: author_id,
        assignment_id: submission.assignment_id,
        course_id: context_id,
        comment: comment
      )
    end
  end

  private
  def teacher_ids
    context.teacher_enrollments.pluck(:user_id)
  end

  def reply_alerts_on?
    SettingsService.get_settings(object: :school, id: 1)['reply_alerts']
  end
end