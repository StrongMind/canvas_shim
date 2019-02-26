module PipelineService
  module Nouns
    class ConversationParticipant      
      class Builder < ActiveRecord::Base
        self.table_name = "conversation_participants"
        
        def initialize object:
          @conversation_participant = object
        end

        def call
          Queries::FindByID.query(self, @conversation_participant)
        end

        private

        attr_reader :conversation_participant
      end
    end
  end
end
