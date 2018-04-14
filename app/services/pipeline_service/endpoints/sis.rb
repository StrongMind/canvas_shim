module PipelineService
  module Endpoints
    class SIS
      def initialize(message, http_client: HTTParty)
        @message = message
        @api_key = ENV['SIS_ENROLLMENT_UPDATE_API_KEY']
        @endpoint = ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT']
        @http_client = http_client
      end

      def call
        raise 'Missing config' if missing_config?
        return unless message
        post if student_enrollment?
      end

      private

      attr_reader :message, :http_client, :api_key, :endpoint

      def missing_config?
        [@api_key, @endpoint].any?(&:nil?)
      end

      def student_enrollment?
        message[:noun] == 'StudentEnrollment'
      end

      def build_endpoint
        endpoint + '?apiKey=' + api_key
      end

      def post
        http_client.post(
          build_endpoint,
          body: HashWithIndifferentAccess.new(
            JSON.parse(message[:data].to_json)
          ).delete_blank.to_json
        )
      end
    end
  end
end
