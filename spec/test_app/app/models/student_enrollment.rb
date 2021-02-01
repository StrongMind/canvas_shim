class StudentEnrollment < Enrollment
  scope :active, -> { where("workflow_state IS NULL OR workflow_state<>'deleted'") }

  def self.recompute_final_score(thing, other_thing)
  end
end