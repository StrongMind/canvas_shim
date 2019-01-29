module CanvasShim
  class MessageJSONBuilder < ActiveRecord::Base
    self.table_name = "messages"

    def self.call(id:)
      MessageJSONBuilder.find(id).to_json(include_root: false)
    end
  end
end
