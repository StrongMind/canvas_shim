
  class CsAlertsController < ApplicationController
    before_action :build_alert, only: :create
    def index
      @alerts = AlertsService::Client.list(@current_user.id).payload
    end

    def destroy
      AlertsService::Client.destroy(params[:alert_id])
      redirect_to(cs_alerts_path)
    end

    if Rails.application.class.parent_name == 'TestApp'
      def create
        result = AlertsService::Client.create(@alert)
        redirect_to(cs_alerts_path)
      end
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
