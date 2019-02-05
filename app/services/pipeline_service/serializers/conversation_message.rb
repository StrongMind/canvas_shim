module PipelineService
  module Serializers
    class ConversationMessage
      def initialize object:
        @conversation_message = object
      end

      def call
        CanvasShim::ConversationMessageJSONBuilder.call(id: conversation_message.id)
      end

      def additional_identifiers
        { conversation_id: @conversation_message.conversation_id }
      end

      private

      attr_reader :conversation_message
    end
  end
end
