StudentEnrollment.class_eval do
  def days_since_active
    days_since(last_activity_at)
  end

  def days_since_last_submission
    days_since(last_submission)
  end

  def missing_assignments_count
    user.submissions.count do |sub|
      sub.missing? || (sub.grader_id == 1 && sub.late?)
    end
  end

  def current_score
    scores.first.try(:current_score) || 0
  end

  private
  def days_since(field)
    (Time.now.to_date - field.to_date).to_i
  end

  def last_submission
    user.submissions
    .where("context_code = ? AND grader_id <> 1", "course_#{course.id}")
    .order('submitted_at DESC')
    .first.try(:submitted_at) || course.start_at
  end
end