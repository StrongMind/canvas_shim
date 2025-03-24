class CsAlertsController < ShimController
  include ERB::Util

  def index
  end

  def teacher_alerts
    alerts_response = AlertsService::Client.teacher_alerts(@current_user.id, params[:page], params[:per_page])
    
    # Format the alerts while preserving the pagination metadata
    formatted_response = {
      alerts: mapped_alerts(alerts_response.alerts),
      pagination: alerts_response.pagination
    }
    
    render json: formatted_response
  end

  def destroy
    AlertsService::Client.destroy(params[:id])
  end

  def bulk_delete
    AlertsService::Client.bulk_delete(params[:alert_ids])
  end

  private
  def mapped_alerts(alerts)
    alerts.map do |alert|
      assignment = alert.assignment

      alert.as_json(include_root: false).merge(
        "alert_id" => alert.alert_id,
        "student_name" => alert.student.name,
        "assignment_name" => assignment.try(:name),
        "course_name" => assignment.try(:course).try(:name) || "-",
        "alert_link" => alert_link(alert),
        "updated_at" => alert.updated_at.try(:in_time_zone).try(:strftime, "%m/%d/%y %I:%M %P")
      )
    end
  end

  def alert_link(alert)
    if alert.class == AlertsService::Alerts::StudentDiscussionEntry
      "/courses/#{alert.assignment.course.id}/assignments/#{alert.assignment.id}#discussion_subentries"
    else
      [
        "/courses/#{alert.assignment.course.id}/gradebook/speed_grader?assignment_id=#{alert.assignment.id}#",
        url_encode("{\"student_id\":\"#{alert.student.id}\"}")
      ].join
    end
  end
end
