ApplicationController.class_eval do
  prepend_view_path CanvasShim::Engine.root.join('app', 'views')

  def granted_permission?(task)
    is_admin = @current_user.roles(Account.site_admin).include? 'admin'
    is_admin || @current_user.enrollments.active.any? { |e| e.has_permission_to?(task) }
  end
  helper_method :granted_permission?

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
