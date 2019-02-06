module CanvasShim
  class ConversationParticipantJSONBuilder < ActiveRecord::Base
    self.table_name = "conversation_participants"

    def self.call(id:)
      # Dont include root.  See active record initializer
      ConversationParticipantJSONBuilder.find(id).as_json(include_root: false)
    end
  end
end
