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

      def prefix
        if Rails.env == 'development'
          "http://#{ENV['CANVAS_DOMAIN']}:3000/api"
        else
          "https://#{ENV['CANVAS_DOMAIN']}/api"
        end
      end

      attr_reader :conversation_message, :api_client
    end
  end
end
