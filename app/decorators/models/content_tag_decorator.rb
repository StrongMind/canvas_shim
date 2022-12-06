ContentTag.class_eval do
  after_commit -> do
    return if self.content_type == "LearningOutcome"
    PipelineService::V2.publish self
  end
  after_commit -> do
    return unless course
    return if self.content_type == "LearningOutcome"
    PipelineService.publish PipelineService::Nouns::ModuleItem.new(self)
  end
end
