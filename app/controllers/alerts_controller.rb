class AlertsController < ApplicationController
  def index
    redirect_to "/" unless @context.teacher_enrollments.any?
    @alerts = [1]
  end
end