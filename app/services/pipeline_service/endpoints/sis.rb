module PipelineService
  module Endpoints
    class SIS
      def initialize(message:, noun:, id:, args:)
        @message = message
        @api_key = ENV['SIS_ENROLLMENT_UPDATE_API_KEY']
        @endpoint = ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT']
        @http_client = args[:http_client] || HTTParty
        @noun = noun
      end

      def call
        check_config
        filter
        post
      end

      private

      attr_reader :message, :http_client, :api_key, :endpoint, :noun

      def check_config
        raise 'Missing config' if missing_config?
      end

      def missing_config?
        [@api_key, @endpoint].any?(&:nil?)
      end

      def filter
        @message = nil unless noun == 'student_enrollment'
      end

      def build_endpoint
        endpoint + '?apiKey=' + api_key
      end

      def post
        return unless message
        http_client.post(build_endpoint, body: message.to_json, headers: { 'Content-Type' => 'application/json' })
      end
    end
  end
end
