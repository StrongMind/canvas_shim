ConversationMessage.class_eval do
  after_save { PipelineService.publish_as_v2(self) }
  before_destroy { PipelineService.publish_as_v2(self) }
end
