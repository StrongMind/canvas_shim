class ObserversController < ApplicationController
  def index
    render_unauthorized_action unless can_see_observer_dashboard?
  end

  private
  def can_see_observer_dashboard?
    @current_user && (
      @current_user.roles(@domain_root_account).include?('admin') ||
      @current_user.observer_enrollments.any?
    )
  end
end