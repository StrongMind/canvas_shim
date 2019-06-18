class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def update_enrollment_last_activity_at; end
  def content_tag_redirect; end
end
