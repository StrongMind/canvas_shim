module PipelineService
  class PipelineClient
    class SISEndpoint
      ENDPOINT = 'https://www.example-endpoint.com'

      def initialize(message)
        @message = message
      end

      def call
        post
      end

      private

      attr_reader :message

      def post
        HTTParty.post(
          ENDPOINT,
          body: HashWithIndifferentAccess.new(
            JSON.parse(message.to_json)
          ).delete_blank.to_json
        )
      end
    end
  end
end
