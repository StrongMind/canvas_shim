module PipelineService
  module Nouns
    class ConversationMessage
      class Builder < ActiveRecord::Base
        self.table_name = "conversation_message"

        def initialize object:
          @conversation_message = object
        end

        def call
          Queries::FindByID.query(self, @conversation_message)
        end

        def self.additional_identifier_fields
          [:conversation_id]
        end

        private

        attr_reader :conversation_message
      end
    end
  end
end
