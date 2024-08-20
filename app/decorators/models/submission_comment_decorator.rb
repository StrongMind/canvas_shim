SubmissionComment.class_eval do
  after_create :send_feedback_alert, if: :is_submission_comment_from_student?

  after_commit -> { PipelineService.publish_as_v2(self) }

  def is_submission_comment_from_student?
    return unless reply_alerts_on? && context.is_a?(Course)
    context_student_ids.include?(author_id)
  end

  def send_feedback_alert
    context_teacher_ids.each do |teacher_id|
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
  def context_teacher_ids
    context.teacher_enrollments.pluck(:user_id)
  end

  def context_student_ids
    context.student_enrollments.pluck(:user_id)
  end

  def reply_alerts_on?
    SettingsService.get_settings(object: :school, id: 1)['reply_alerts']
  end
end
