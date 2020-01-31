ContentMigration.class_eval do
  after_save :publish_after_imported

  def publish_after_imported
    if changes[:workflow_state] and self.workflow_state == "imported"
      PipelineService::V2.publish(self)
    end
  end


end