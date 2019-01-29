module PipelineService
  module Serializers
    class Conversation
      def initialize object:
        @conversation = object
        @api_client = Pandarus::Client.new(prefix: prefix, token: ENV['STRONGMIND_INTEGRATION_KEY'])
      end

      def call
        CanvasShim::ConversationJSONBuilder.call(id: conversation.id)
      end

      private

      def prefix
        if Rails.env == 'development'
          "http://#{ENV['CANVAS_DOMAIN']}:3000/api"
        else
          "https://#{ENV['CANVAS_DOMAIN']}/api"
        end
      end

      attr_reader :conversation, :api_client
    end
  end
end
