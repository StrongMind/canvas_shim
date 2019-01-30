module PipelineService
  module Serializers
    class ConversationParticipant
      def initialize object:
        @conversation_participant = object
        @api_client = Pandarus::Client.new(prefix: prefix, token: ENV['STRONGMIND_INTEGRATION_KEY'])
      end

      def call
        CanvasShim::ConversationParticipantJSONBuilder.call(id: conversation_participant.id)
      end

      private

      def prefix
        if Rails.env == 'development'
          "http://#{ENV['CANVAS_DOMAIN']}:3000/api"
        else
          "https://#{ENV['CANVAS_DOMAIN']}/api"
        end
      end

      attr_reader :conversation_participant, :api_client
    end
  end
end
