module PipelineService
  module API
    class Publish
      def initialize(object, args={})
        @object         = object
        @queue_client   = args[:queue_client] || Delayed::Job
        @command_class  = args[:command_class] || PipelineService::Commands::Publish
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
        Subscription.new(event: 'graded_out', listener: SIS)
      end

      def command
        command_class.new(
          object: object,
          event_subscriptions: subscriptions
        )
      end
    end
  end
end
