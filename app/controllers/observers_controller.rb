class ObserversController < ApplicationController
  def index
    non_observer_redirect unless observer_dashboard_enabled?
    js_env(
      show_progress_grades: !!SettingsService.get_settings(object: :user, id: @current_user.id)["show_progress_grades"]
    )
  end

  private
  def non_observer_redirect
    flash[:error] = "This feature has not been enabled or you are not currenty observing students."
    redirect_to "/"
  end
end