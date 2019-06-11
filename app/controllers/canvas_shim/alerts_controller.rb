module CanvasShim
  class AlertsController < ApplicationController
    def index
      @alerts = AlertsService::Client.list(1).payload
    end

    def destroy
      AlertsService::Client.destroy(params[:alert_id])
      redirect_to(alerts_path)
    end

    def create
      AlertsService::Client.create(
        AlertsService::Alerts::MaxAttemptsReached.new(
          teacher_id: 1,
          student_id: 1,
          assignment_id: 1,
        )
      )
      redirect_to(alerts_path)
    end
  end
end