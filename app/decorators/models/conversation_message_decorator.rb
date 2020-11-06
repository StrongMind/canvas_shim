ConversationMessage.class_eval do
  after_commit :publish_as_v2_if_conversation_id

  def publish_as_v2_if_conversation_id
    PipelineService.publish_as_v2(self) if conversation_id
  end
end
