module PipelineService
  module API
    class Publish
      def initialize(object, args={})
        @object         = object
        @queue_client   = args[:queue_client] || Delayed::Job
        @command_class  = args[:command_class] || PipelineService::Commands::Send
        @jobs           = [Jobs::PostToPipeline, Jobs::PostToSIS]
      end

      def call
        enqueue_jobs
      end

      private

      attr_reader :object, :queue_client, :jobs, :command_class

      def run_command
        command.call
      end

      def enqueue_jobs
        jobs.each do |job|
          queue_client.enqueue job.new(object: object)
        end
      end

      def command
        command_class.new(object: object)
      end
    end
  end
end
