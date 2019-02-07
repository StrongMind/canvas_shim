module CanvasShim
  class ConversationMessageJSONBuilder < ActiveRecord::Base
    self.table_name = "conversation_messages"

    def self.call(id:)
      # Dont include root.  See active record initializer
      ConversationMessageJSONBuilder.find(id).as_json(include_root: false)
    end
  end
end
