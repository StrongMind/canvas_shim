ConversationMessage.class_eval do
  after_commit { PipelineService.publish(self) }
end
