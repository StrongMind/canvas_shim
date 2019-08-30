Submission.class_eval do
  after_update :record_excused_removed

  def valid?(*args)
    return false if self.grader_id.to_i < 1 and self.excused == true
    super
  end

  def record_excused_removed
    if self.changes[:excused] == [true, false] and self.grader_id.to_i >= 1
      self.submission_comments.create(comment: "This assignment is no longer excused.")
    end
  end
end
