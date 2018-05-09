# The API calls Commands
#
# Class methods map to Commands
# ie: PipelineService::API::Publish calls PipelineService::Commands::Publish
#
module PipelineService
  module API
    class Publish
      def initialize(object, args={})
        @object        = object
        @command_class = args[:command_class] || PipelineService::Commands::Publish
        @queue         = args[:queue] || Delayed::Job
        @noun          = args[:noun]
      end

      def call
        queue.enqueue self
      end

      def perform
        command.call
      end

      private

      attr_reader :object, :jobs, :command_class, :queue, :noun

      def subscriptions
        Events::Subscription.new(
          event: 'graded_out',
          responder: Events::Responders::SIS
        )
      end

      def command
        command_class.new(
          object: object,
          event_subscriptions: subscriptions,
          noun: noun
        )
      end
    end
  end
end
