ContextModuleProgression.class_eval do
  def prerequisites_satisfied?
    enrollment       = Enrollment.where(user_id: user.id, course_id: context_module.context.id).first
    settings         = enrollment ? SettingsService.get_enrollment_settings(id: enrollment.id) : {}
    sequence_control = settings.fetch('sequence_control', true)

    sequence_control ? ContextModuleProgression.prerequisites_satisfied?(user, context_module) : true
  end
end
