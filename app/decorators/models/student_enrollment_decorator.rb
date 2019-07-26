StudentEnrollment.class_eval do
  def days_since_active
    days_since(last_activity_at)
  end

  def days_since_last_submission
    days_since(last_submission)
  end

  def missing_assignments_count
    subs = user.submissions.where(context_code: "course_#{course.id}")
    subs.missing.merge(
      subs.late.where(grader_id: 1)
    ).count
  end

  def current_score
    scores.first.try(:current_score) || 0
  end

  def string_progress
    cp = CourseProgress.new(course, user)
    "#{cp.requirement_completed_count.to_i}/#{cp.requirement_count.to_i}"
  end

  private
  def days_since(field)
    return "N/A" unless field
    (Time.now.to_date - field.to_date).to_i
  end

  def last_submission
    user.submissions.where(
      "submitted_at IS NOT NULL AND context_code = ? " \
      "AND grader_id IS NULL OR grader_id <> 1",
      "course_#{course.id}"
    ).order('submitted_at DESC')
    .first.try(:submitted_at)
  end
end