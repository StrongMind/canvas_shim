module DomainEvents
  module Listeners
    class SIS
      def initialize(message:, args: {})
        @message = message
        @api_key = ENV['SIS_ENROLLMENT_UPDATE_API_KEY']
        @endpoint = ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT']
        @http_client = args[:http_client] || HTTParty
      end

      def call
        raise 'Missing config' if missing_config?
        post
      end

      private

      attr_reader :message, :http_client, :api_key, :endpoint, :filter

      def missing_config?
        [@api_key, @endpoint].any?(&:nil?)
      end

      def build_endpoint
        endpoint + '?apiKey=' + api_key
      end

      def post
        return unless message
        http_client.post(
          build_endpoint,
          body: message[:data].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      end
    end
  end
end
