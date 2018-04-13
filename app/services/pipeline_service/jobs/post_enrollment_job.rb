module PipelineService
  module Jobs
    class PostEnrollmentJob
      def initialize(object:)
        @object  = object
      end

      def perform
        Commands::Send.new(object: object).call
      end

      private

      attr_reader :object
    end
  end
end
