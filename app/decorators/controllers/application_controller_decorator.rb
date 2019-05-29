ApplicationController.class_eval do
  prepend_view_path CanvasShim::Engine.root.join('app', 'views')

  def score_threshold
    SettingsService.get_settings(object: :school, id: 1)['score_threshold'].to_f
  end
  
  def threshold_set?
    score_threshold.positive?
  end

  def course_threshold_prevention_on?
    SettingsService.get_settings(object: :school, id: 1)['course_threshold_prevention']
  end

  def valid_threshold?(threshold)
    !threshold.negative? && threshold <= 100
  end
  
  def strongmind_update_enrollment_last_activity_at
    return if logged_in_user != @current_user
    instructure_update_enrollment_last_activity_at
  end

  alias_method :instructure_update_enrollment_last_activity_at, :update_enrollment_last_activity_at
  alias_method :update_enrollment_last_activity_at, :strongmind_update_enrollment_last_activity_at
end
