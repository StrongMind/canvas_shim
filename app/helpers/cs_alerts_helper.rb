module CsAlertsHelper
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