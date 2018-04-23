module PipelineService
  module Jobs
    class PostToPipeline
      def initialize(object:)
        @object  = object
      end

      def perform
        Commands::Publish.new(object: object).call
      end

      private

      attr_reader :object
    end
  end
end
