StudentEnrollment.class_eval do
  def days_since_active
    days_since(last_activity_at)
  end

  def days_since_last_submission
    days_since(last_submission)
  end

  def missing_assignments_count
    user.submissions.where(
      "context_code = ? AND cached_due_date < ?",
      "course_#{course.id}",
      1.hour.ago
    ).where("grader_id = 1 OR workflow_state = 'unsubmitted'").count
  end

  def current_score
    scores.first.try(:current_score) || 0.0
  end

  def string_progress
    cp = CourseProgress.new(course, user)
    "#{cp.requirement_completed_count(cached: true).to_i}/#{cp.requirement_count(cached: true).to_i}"
  end

  def last_submission_formatted
    last_submission ? last_submission.strftime("%B %d, %Y") : "N/A"
  end

  private
  def days_since(field)
    return "N/A" unless field
    (Time.now.to_date - field.to_date).to_i
  end

  def last_submission
    query = "submitted_at IS NOT NULL AND context_code = 'course_#{course.id}'"

    user.submissions.where(
      "#{query} AND grader_id IS NULL OR #{query} AND grader_id <> 1"
    ).order('submitted_at DESC').first.try(:submitted_at)
  end
end