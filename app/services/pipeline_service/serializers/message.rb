module PipelineService
  module Serializers
    class Message
      def initialize object:
        @message = object
        @api_client = Pandarus::Client.new(prefix: prefix, token: ENV['STRONGMIND_INTEGRATION_KEY'])
      end

      def call
        CanvasShim::MessageJSONBuilder.call(id: message.id)
      end

      private

      def prefix
        if Rails.env == 'development'
          "http://#{ENV['CANVAS_DOMAIN']}:3000/api"
        else
          "https://#{ENV['CANVAS_DOMAIN']}/api"
        end
      end

      attr_reader :message, :api_client
    end
  end
end
