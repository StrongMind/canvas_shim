ApplicationController.class_eval do
  prepend_view_path CanvasShim::Engine.root.join('app', 'views')

  def course_score_threshold?
    threshold = SettingsService.get_settings(object: :course, id: @context.try(:id))['passing_threshold'].to_f
    threshold if threshold.positive?
  end

  def score_threshold
    course_score_threshold? || SettingsService.get_settings(object: :school, id: 1)['score_threshold'].to_f
  end
  
  def threshold_set?
    score_threshold.positive?
  end

  def course_threshold_enabled?
    SettingsService.get_settings(object: :school, id: 1)['course_threshold_enabled']
  end

  def post_enrollment_thresholds_enabled?
    SettingsService.get_settings(object: :school, id: 1)['enable_post_enrollment_threshold_updates']
  end

  def disable_module_editing_on?
    SettingsService.get_settings(object: :school, id: 1)['disable_module_editing']
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
