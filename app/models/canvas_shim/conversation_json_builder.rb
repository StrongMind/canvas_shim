module CanvasShim
  class ConversationJSONBuilder < ActiveRecord::Base
    self.table_name = "conversations"

    def self.call(id:)
      # Dont include root.  See active record initializer
      ConversationJSONBuilder.find(id).as_json(include_root: false)
    end
  end
end
