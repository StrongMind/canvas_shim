ApplicationController.class_eval do
  helper CanvasShim::Engine.helpers
  prepend_view_path CanvasShim::Engine.root.join('app', 'views')

  def strongmind_update_enrollment_last_activity_at
    return if logged_in_user != @current_user
    instructure_update_enrollment_last_activity_at
  end

  alias_method :instructure_update_enrollment_last_activity_at, :update_enrollment_last_activity_at
  alias_method :update_enrollment_last_activity_at, :strongmind_update_enrollment_last_activity_at

  helper CanvasShim::ApplicationHelper
end
