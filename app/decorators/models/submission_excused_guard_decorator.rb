Submission.class_eval do
  before_update :guard_excused
  after_update :record_excused_removed

  def guard_excused
      if self.grader_id.to_i < 1 and self.excused == true
        self.score = self.changes[:score][0] if self.changes[:score]
        self.excused =  true
      end
  end

  def record_excused_removed
    if self.changes[:excused] == [true, false]
      self.submission_comments.create(comment: "This assignment is no longer excused.")
    end

  end

end
