# The API calls Commands
#
# Class methods map to Commands
# ie: PipelineService::API::Publish calls PipelineService::Commands::Publish
#
module PipelineService
  module API
    class Publish
      def initialize(object, args={})
        @object = object
        @changes = object.try(:changes)
        @noun = args[:noun]
        @args = args
        configure_dependencies
      end

      def call
        return if SettingsService.get_settings(object: :school, id: 1)['disable_pipeline']
        queue.enqueue(self, priority: 1000000, strand: 'pipeline_service')
      end

      def perform
        command.call
      end

      private

      attr_reader :object, :jobs, :command_class, :queue, :noun, :changes

      def configure_dependencies
        @command_class = @args[:command_class] || Commands::Publish
        @queue         = @args[:queue] || Delayed::Job
      end


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
          noun: noun,
          changes: changes
        )
      end
    end
  end
end
