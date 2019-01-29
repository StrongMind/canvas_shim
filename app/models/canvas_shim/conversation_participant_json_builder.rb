module CanvasShim
  class ConversationParticipantJSONBuilder < ActiveRecord::Base
    self.table_name = "conversation_participants"

    def self.call(id:)
      ConversationParticipantJSONBuilder.find(id).to_json(include_root: false)
    end
  end
end
