class CsAlertsController < ApplicationController
  def index
    @alerts = AlertsService::Client.teacher_alerts(@current_user.id).payload
  end

  def destroy
    AlertsService::Client.destroy(params[:alert_id])
  end

  def bulk_delete
    AlertsService::Client.bulk_delete(params[:alert_ids])
  end

  def alert_link(alert)
    if alert.class == StudentDiscussionEntry
      "/courses/#{alert.assignment.course.id}/assignments/#{alert.assignment.id}"
    else
      [
        "/courses/#{alert.assignment.course.id}/gradebook/speed_grader?assignment_id=#{alert.assignment.id}#",
        url_encode("{\"student_id\":\"#{alert.student.id}\"}")
      ].join
    end
  end

  helper_method :alert_link
end
