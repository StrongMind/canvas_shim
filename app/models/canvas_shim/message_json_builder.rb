module CanvasShim
  class MessageJSONBuilder < ActiveRecord::Base
    self.table_name = "messages"

    def self.call(id:)
      # Dont include root.  See active record initializer
      MessageJSONBuilder.find(id).to_json(include_root: false)
    end
  end
end
