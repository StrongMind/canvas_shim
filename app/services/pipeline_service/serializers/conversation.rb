module PipelineService
  module Serializers
    class Conversation
      def initialize object:
        @conversation = object
      end

      def call
        Builders::ConversationJSONBuilder.call(conversation)
      end

      private

      attr_reader :conversation
    end
  end
end
