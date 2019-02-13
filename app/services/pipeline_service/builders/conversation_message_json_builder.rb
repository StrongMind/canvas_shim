module PipelineService
  module Builders
    class ConversationMessageJSONBuilder < ActiveRecord::Base
      self.table_name = "conversation_messages"

      def self.call(noun)
        # Dont include root.  See active record initializer
        Queries::FindByID.query(noun)
      end
    end
  end
end