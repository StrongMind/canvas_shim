class ConversationBackfiller
  def self.call
    Conversation.find_each do |conversation|
      conversation.save

      conversation.conversation_participants.each do |participant|
        participant.save
      end

      conversation.conversation_messages.each do |message|
        message.save
      end
    end
  end
end
