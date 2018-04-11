module PipelineService
  module API
    class Publish
      def initialize(object, args={})
        @object = object
        @queue_client = args[:queue_client] || Delayed::Job
        @command_class = args[:command_class] || PipelineService::Commands::Send
        @job = Jobs::PostEnrollmentJob
      end

      def call
        enqueue_command
      end

      private

      attr_reader :object, :queue_client, :job, :command_class

      def run_command
        command.call
      end

      def enqueue_command
        queue_client.enqueue job.new(object: object)
      end

      def command
        command_class.new(object: object)
      end
    end
  end
end
