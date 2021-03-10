Submission.class_eval do
  after_commit :bust_context_module_cache
  after_commit -> { PipelineService::V2.publish(self) }
  after_commit -> { PipelineService::V2.publish(self.assignment) }
  after_save :send_needs_regrading_alert_if_needed

  after_update :record_excused_removed
  after_save :send_unit_grades_to_pipeline

  def send_unit_grades_to_pipeline
    return unless enable_unit_grade_calculations?
    PipelineService.publish_as_v2(
      PipelineService::Nouns::UnitGrades.new(self)
    )
  end

  def send_needs_regrading_alert_if_needed
    if self.submitted_at_changed and self.grader_id == 1 and self.score == 0 and ["discussion_topic", "basic_lti_launch", "online_upload"].include?(self.submission_type)
      teacher_ids = assignment.course.teacher_enrollments.active.pluck(:user_id)
      teacher_ids.each do |teacher_id|
        AlertsService::Client.create(
          :submission_needs_regrading,
          teacher_id: teacher_id,
          student_id: user.id,
          assignment_id: assignment.id,
          course_id: assignment.course.id,
        )
        end
    end
  end

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

  private
  def teacher
    self.grader || GradesService::Account.account_admin
  end

  def unexcused_comment
    "This assignment is no longer excused. " +
    "Please complete the required work. " +
    "If you have questions, please contact your teacher."
  end

  def user_is_observer?(other_user)
    other_user && context.is_a?(Course) &&
    user_id == other_user.observer_enrollments.concluded.find_by(course: context)&.associated_user_id
  end

  def enable_unit_grade_calculations?
    SettingsService.get_settings(object: :school, id: 1)['enable_unit_grade_calculations'] == true
  end
end
