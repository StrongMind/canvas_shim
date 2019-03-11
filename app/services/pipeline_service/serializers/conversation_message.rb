module PipelineService
  module Serializers
    class ConversationMessage
      def initialize object:
        @conversation_message = object
      end

      def call
        @payload = Builders::ConversationMessageJSONBuilder.call(conversation_message) || {}
      end

      def additional_identifiers
        Helpers::AdditionalIdentifiers.call(payload: @payload, fields: [:conversation_id])
      end

      private

      attr_reader :conversation_message
    end
  end
end
