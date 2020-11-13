Enrollment.class_eval do
  after_commit :ensure_active_scores
  after_commit -> { PipelineService.publish_as_v2(self) }

  def all_scores
    Score.where(enrollment: self)
  end
  
  def ensure_active_scores
    return if !active_student? || active_scores? || !all_scores.one?
    all_scores.first.update(workflow_state: "active")
  end

  def active_scores?
    all_scores.find_by(workflow_state: "active")
  end
end
