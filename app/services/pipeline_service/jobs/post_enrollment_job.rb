module PipelineService
  module Jobs
    class PostEnrollmentJob
      def initialize(api_instance:, message: )
        @api_instance  = api_instance
        @message = message
      end

      def perform
        api_instance.messages_post(message)
      end

      private

      attr_reader :api_instance, :message
    end
  end
end
