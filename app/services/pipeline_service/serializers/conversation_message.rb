module PipelineService
  module Serializers
    class ConversationMessage
      def initialize object:
        @conversation_message = object
      end

      def call
        CanvasShim::ConversationMessageJSONBuilder.call(id: conversation_message.id)
      end

      private

      attr_reader :conversation_message
    end
  end
end
