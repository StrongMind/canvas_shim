Submission.class_eval do
  after_commit :bust_context_module_cache
  after_commit -> { PipelineService::V2.publish(self) }
  after_update :record_excused_removed
  after_save :update_course_completion_cache_after_submit

  def bust_context_module_cache
    if self.previous_changes.include?(:excused)
      touch_context_module
    end
  end

  def touch_context_module
    tags = self&.assignment&.context_module_tags || []

    tags.each do |tag|
      tag.context_module.send_later_if_production(:touch)
    end
  end

  def record_excused_removed
    if changes[:excused] == [true, false]
      submission_comments.create(
        comment: unexcused_comment,
        author: teacher
      )
    end
  end

  def update_course_completion_cache_after_submit
    if changes[:workflow_state] == ['unsubmitted', 'submitted']
      self.assignment.course.calculate_progress(self.assignment.course.enrollments.find_by(user: self.user))
    end
  end

  private
  def teacher
    assignment&.course&.teacher_enrollments&.first&.user
  end

  def unexcused_comment
    "This assignment is no longer excused. " +
    "Please complete the required work. " +
    "If you have questions, please contact your teacher."
  end
end
