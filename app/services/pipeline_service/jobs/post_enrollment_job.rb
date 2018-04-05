module PipelineService
  module Jobs
    class PostEnrollmentJob
      def initialize(command: )
        @command  = command
      end

      def perform
        command.call
      end

      private

      attr_reader :command
    end
  end
end
