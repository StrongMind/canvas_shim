Enrollment.class_eval do
  after_commit :ensure_active_scores
  after_commit :publish_as_v2

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

  private
  def publish_as_v2
    unless guarded_for_deleted_publish? or guarded_for_deleted_while_active?
      PipelineService.publish_as_v2(self)
    end
  end

  def guarded_for_deleted_publish?
    deleted? && !previous_changes.keys.include?("workflow_state")
  end

  def guarded_for_deleted_while_active?
    deleted? && Enrollment.find_by(course: self.course, user: self.user, workflow_state: 'active')
  end

end
