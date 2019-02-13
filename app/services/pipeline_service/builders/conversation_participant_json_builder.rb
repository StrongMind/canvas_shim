module PipelineService
  module Builders
    class ConversationParticipantJSONBuilder < ActiveRecord::Base
      self.table_name = "conversation_participants"

      def self.call(noun)
        # Dont include root.  See active record initializer
        Queries::FindByID.query(noun)
      end
    end
  end
end
