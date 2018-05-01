module PipelineService
  module API
    class Publish
      def initialize(object, args={})
        @object         = object
        @command_class  = args[:command_class] || PipelineService::Commands::Publish
        @args = args
      end

      def call
        Delayed::Job.enqueue self
      end

      def perform
        command.call
      end

      private

      attr_reader :object, :jobs, :command_class, :args

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
