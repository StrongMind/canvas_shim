StudentEnrollment.class_eval do
  def days_since_active
    days_since(last_activity_at)
  end

  def days_since_last_submission
    days_since(last_submission)
  end

  def missing_assignments_count
    user.submissions.count { |sub| sub.missing? || (sub.grader_id == 1 && sub.late?) }
  end

  def current_grade
    scores.first.try(:current_grade)
  end

  private
  def days_since(field)
    (Time.now.to_date - field.to_date).to_i
  end

  def last_submission
    user.submissions.where(
      "context_code = ? AND grader_id <> 1", "course_#{course.id}"
    ).order('graded_at DESC').first || Time.now
  end
end