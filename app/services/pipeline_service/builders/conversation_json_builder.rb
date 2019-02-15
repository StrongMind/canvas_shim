module PipelineService
  module Builders
    class ConversationJSONBuilder < ActiveRecord::Base
      self.table_name = "conversations"

      def self.call(noun)
        # Dont include root.  See active record initializer
        Queries::FindByID.query(self, noun)
      end
    end
  end
end

