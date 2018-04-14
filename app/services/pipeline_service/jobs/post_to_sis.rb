module PipelineService
  module Jobs
    class PostToSIS
      def initialize(object:)
        @object  = object
      end

      def perform
        Commands::Send.new(object: object, endpoint: Endpoints::SIS).call
      end

      private

      attr_reader :object
    end
  end
end
