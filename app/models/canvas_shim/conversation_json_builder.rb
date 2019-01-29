module CanvasShim
  class ConversationJSONBuilder < ActiveRecord::Base
    self.table_name = "conversations"

    def self.call(id:)
      ConversationJSONBuilder.find(id).to_json
    end
  end
end
