class CsAlertsController < ApplicationController
  def index
    @alerts = AlertsService::Client.teacher_alerts(@current_user.id).payload
  end

  def destroy
    AlertsService::Client.destroy(params[:alert_id])
    redirect_to(cs_alerts_path)
  end

  def bulk_delete
    AlertsService::Client.bulk_delete(params[:alert_ids])
  end
end
