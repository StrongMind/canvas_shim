class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :get_current_user
  
  def update_enrollment_last_activity_at
  end

  def get_current_user
    @current_user = User.first
  end
end
