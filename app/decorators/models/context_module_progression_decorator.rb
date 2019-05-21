ContextModuleProgression.class_eval do
  def strongmind_prerequisites_satisfied?
    sequence_control_on? ? instructure_prerequisites_satisfied? : true
  end

  alias_method :instructure_prerequisites_satisfied?, :prerequisites_satisfied?
  alias_method :prerequisites_satisfied?, :strongmind_prerequisites_satisfied?

  def strongmind_locked?
    sequence_control_on? ? instructure_locked? : false
  end

  alias_method :instructure_locked?, :locked?
  alias_method :locked?, :strongmind_locked?

  private
  def sequence_control_on?
    enrollment = Enrollment.where(user_id: user.id, course_id: context_module.context.id).first
    settings = enrollment ? SettingsService.get_enrollment_settings(id: enrollment.id) : {}
    settings.fetch('sequence_control', true)
  end
end
