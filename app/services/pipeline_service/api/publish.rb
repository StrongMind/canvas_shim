module PipelineService
  module API
    class Publish
      def initialize(object, args={})
        @object         = object
        @queue_client   = args[:queue_client] || Delayed::Job
        @command_class  = args[:command_class] || PipelineService::Commands::Send
      end

      def call
        queue_client.enqueue Jobs::PostToPipeline.new(object: object)
      end

      private

      attr_reader :object, :queue_client, :jobs, :command_class

      def run_command
        command.call
      end

      def subscriptions
        Subscription.new(listeners: [SIS])
      end

      def command
        command_class.new(
          object: object,
          events: {
            graded_out: subscriptions
          }
        )
      end
    end
  end
end
