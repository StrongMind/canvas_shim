class CsAlertsController < ApplicationController
  before_action :require_user

  def index
    @alerts = AlertsService::Client.list(@current_user.id).payload
  end

  def destroy
    AlertsService::Client.destroy(params[:alert_id])
    redirect_to(cs_alerts_path)
  end    
end
