ContentTag.class_eval do
  # after_commit -> { PipelineService::V2.publish self }
  after_commit -> do
    binding.pry
    return unless course
    PipelineService.publish PipelineService::Nouns::ModuleItem.new(self)
  end
end
