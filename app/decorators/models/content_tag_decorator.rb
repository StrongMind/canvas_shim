ContentTag.class_eval do
  after_commit -> do
    return if self.tag_type == "learning_outcome"
    PipelineService::V2.publish self
  end
  after_commit -> do
    return unless course
    return if self.tag_type == "learning_outcome"
    PipelineService.publish PipelineService::Nouns::ModuleItem.new(self)
  end
end
