module PipelineService
  module Endpoints
    class SIS

      def initialize(message:, args: {})
        @message = message
        @api_key = ENV['SIS_ENROLLMENT_UPDATE_API_KEY']
        @endpoint = ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT']
        @http_client = args[:http_client] || HTTParty
        @filter = Filter.new(message: message)
      end

      def call
        check_config
        run_filter
        post
      end

      private

      attr_reader :message, :http_client, :api_key, :endpoint, :filter

      def check_config
        raise 'Missing config' if missing_config?
      end

      def missing_config?
        [@api_key, @endpoint].any?(&:nil?)
      end

      def run_filter
        @message = nil unless filter.match?
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
