module PipelineService
  module Serializers
    class Conversation
      def initialize object:
        @conversation = object
      end

      def call
        CanvasShim::ConversationJSONBuilder.call(id: conversation.id)
      end

      private

      attr_reader :conversation
    end
  end
end
