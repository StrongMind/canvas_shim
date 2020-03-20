class ObserversController < ApplicationController
  def index
    render_unauthorized_action unless @current_user.observer_enrollments.any?
  end
end