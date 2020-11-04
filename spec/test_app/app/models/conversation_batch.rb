class ConversationBatch < ActiveRecord::Base
  before_save :serialize_conversation_message_ids

  def conversation_message_ids
    @conversation_message_ids ||= (read_attribute(:conversation_message_ids) || '').split(',').map(&:to_i)
  end

  def serialize_conversation_message_ids
    write_attribute :conversation_message_ids, conversation_message_ids.join(',')
  end
end