module PipelineService
  module Serializers
    class ConversationParticipant
      def initialize object:
        @conversation_participant = object
      end

      def call
        CanvasShim::ConversationParticipantJSONBuilder.call(id: conversation_participant.id)
      end

      def additional_identifers
        { conversation_id: @conversation_participant.conversation_id }
      end

      private

      attr_reader :conversation_participant, :api_client
    end
  end
end
