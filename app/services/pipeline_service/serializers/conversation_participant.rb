module PipelineService
  module Serializers
    class ConversationParticipant      
      def initialize object:
        @conversation_participant = object
      end

      def call
        @payload = Builders::ConversationParticipantJSONBuilder.call(conversation_participant)
      end

      def self.additional_identifier_fields
        [:conversation_id]
      end

      private

      attr_reader :conversation_participant
    end
  end
end
