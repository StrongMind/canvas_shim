Submission.class_eval do
  after_commit :bust_context_module_cache
  after_commit -> { PipelineService::V2.publish(self) }
  after_commit -> { PipelineService::V2.publish(self.assignment) }
  after_save :set_cached_regrade_alert_applicable
  after_save :send_delayed_regrading_alert, if: :get_cached_regrade_alert_applicable

  after_update :record_excused_removed
  after_save :send_unit_grades_to_pipeline
  after_save :send_guided_practice_submitted_alert, if: Proc.new { |submission| submission.assignment.present? && submission.assignment.assignment_group_name == 'Guided Practice' && submitted_at_changed? && expose_guided_practice_submission_alerts }
  validates :body, length: { maximum: 20_000 }


  def send_unit_grades_to_pipeline
    return unless enable_unit_grade_calculations?
    PipelineService.publish_as_v2(
      PipelineService::Nouns::UnitGrades.new(self)
    )
  end

  def set_cached_regrade_alert_applicable
    cache_key = "submission/#{id}/regrading_alert_applicable"
    if regrade_alert_applicable?
      Rails.cache.write(cache_key, true, expires_in: 4.hours)
    else
      Rails.cache.delete(cache_key)
    end
  end

  def get_cached_regrade_alert_applicable
    cache_key = "submission/#{id}/regrading_alert_applicable"
    Rails.cache.read(cache_key)
  end

  def regrade_alert_applicable?
    submission_type != 'discussion_topic' && submitted_at_changed? && grader_id == 1 && SettingsService.get_settings(object: :school, id: 1)['enable_regrading_alert']
  end

  def send_delayed_regrading_alert
    send_later_enqueue_args(:send_needs_regrading_alert, run_at: 5.minutes.from_now)
  end

  def send_needs_regrading_alert
    if get_cached_regrade_alert_applicable
      cache_key = "submission/#{id}/regrading_alert_applicable"
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
      Rails.cache.delete(cache_key)
    end
  end

  def send_guided_practice_submitted_alert
    teacher_ids = assignment.course.teacher_enrollments.active.pluck(:user_id)
    teacher_ids.each do |teacher_id|
      AlertsService::Client.create(
        :guided_practice_submitted,
        teacher_id: teacher_id,
        student_id: user.id,
        assignment_id: assignment.id,
        course_id: assignment.course.id,
        )
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

  def expose_guided_practice_submission_alerts
    return true if Rails.env.development? || Rails.env.test?
    Rails.configuration.launch_darkly_client.variation("expose-guided-practice-submitted-alerts", @launch_darkly_user, false)
  end
end
