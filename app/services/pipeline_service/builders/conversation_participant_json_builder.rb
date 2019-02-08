module PipelineService
  module Builders
    class ConversationParticipantJSONBuilder < ActiveRecord::Base
      self.table_name = "conversation_participants"

      def self.call(active_record_object)
        # Dont include root.  See active record initializer
        Queries::FindByID.query(active_record_object)
      end
    end
  end
end
