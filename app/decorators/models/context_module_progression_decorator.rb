ContextModuleProgression.class_eval do
  def strongmind_prerequisites_satisfied?
    enrollment = Enrollment.where(user_id: user.id, course_id: context_module.context.id).first
    settings = SettingsService.get_enrollment_settings(id: enrollment.id)
    sequence_control = settings.fetch('sequence_control', true)
    sequence_control ? instructure_prerequisites_satisfied? : true
  end

  alias_method :instructure_prerequisites_satisfied?, :prerequisites_satisfied?
  alias_method :prerequisites_satisfied?, :strongmind_prerequisites_satisfied?
end
