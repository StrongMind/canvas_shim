ContextModuleProgression.class_eval do
  after_commit :publish_course_progress
  after_commit -> { PipelineService::V2.publish self }

  def locked?
    return false unless sequence_control_on?
    workflow_state == "locked"
  end

  def uncollapse!
    return unless self.id?
    return unless self.collapsed?
    retry_count = 0
    begin
      self.reload
      self.collapsed = false
      self.save
    rescue ActiveRecord::StaleObjectError
      if retry_count < 5
        retry_count += 1
        retry
      else
        raise
      end
    end
  end

  private

  def publish_course_progress
    return unless Enrollment.exists?(
      user_id: user.id,
      type: 'StudentEnrollment',
      course_id: context_module.context.id
    )

    PipelineService.publish_as_v2(
      PipelineService::Nouns::CourseProgress.new(self)
    )
  end

  def sequence_control_on?
    enrollment = StudentEnrollment.active.where(user_id: user.id, course_id: context_module.context.id).first
    settings = enrollment ? SettingsService.get_enrollment_settings(id: enrollment.id) : {}
    if Account.first.name == 'Primavera Online High School' || "iSucceed Virtual High School"
      false
    else
      settings.fetch('sequence_control', true)
    end
  end

end
