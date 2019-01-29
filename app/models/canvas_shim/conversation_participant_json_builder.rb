module CanvasShim
  class ConversationParticipantJSONBuilder < ActiveRecord::Base
    self.table_name = "conversation_participants"

    def self.call(id:)
      ConversationParticipantJSONBuilder.find(id).to_json
    end
  end
end
