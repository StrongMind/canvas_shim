module PipelineService
  module API
    class Publish
      def initialize(object, args={})
        @object         = object
        @command_class  = args[:command_class] || PipelineService::Commands::Publish
        @args = args
        @queue = args[:queue] || Delayed::Job
      end

      def call
        queue.enqueue self
      end

      def perform
        command.call
      end

      private

      attr_reader :object, :jobs, :command_class, :args, :queue

      def subscriptions
        Events::Subscription.new(event: 'graded_out', responder: Events::Responders::SIS)
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
