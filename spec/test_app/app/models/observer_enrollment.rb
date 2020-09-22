class ObserverEnrollment < Enrollment
  scope :active, -> { where("workflow_state IS NULL OR workflow_state<>'deleted'") }

  def destroy
    update(workflow_state: "deleted")
  end
end
