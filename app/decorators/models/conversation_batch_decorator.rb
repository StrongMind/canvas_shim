ConversationBatch.class_eval do
  after_save :publish_messages_as_v2, if: -> { workflow_state_changed? && sent? }

  def publish_messages_as_v2
    conversation_message_ids.each do |cm_id|
      message = ConversationMessage.find_by(id: cm_id)
      # PipelineService.publish_as_v2(message) if message
    end
  end
end
