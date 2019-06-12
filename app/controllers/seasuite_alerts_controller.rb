
  class SeasuiteAlertsController < ApplicationController
    before_action :build_alert, only: :create
    def index
      @alerts = AlertsService::Client.list(1).payload
    end

    def destroy
      AlertsService::Client.destroy(params[:alert_id])
      redirect_to(seasuite_alerts_path)
    end

    def create
      result = AlertsService::Client.create(@alert)
      redirect_to(seasuite_alerts_path)
    end
    
    private
    
    def build_alert
      @alert = AlertsService::Alerts::MaxAttemptsReached.new(
        teacher_id: @current_user.id,
        student_id: User.last.id,
        assignment_id: Assignment.first.id,
      )
    end
  end
