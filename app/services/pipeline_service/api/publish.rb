# The API calls Commands
#
# Class methods map to Commands
# ie: PipelineService::API::Publish calls PipelineService::Commands::Publish
module PipelineService
  module API
    class Publish
      attr_reader :object

      def initialize(object, args={})
        @object = Models::Noun.new(object)
        @changes = object.try(:changes)
        @command_class = args[:command_class] || Commands::Publish
        @queue         = args[:queue] || Delayed::Job
      end

      def call
        return if SettingsService.get_settings(object: :school, id: 1)['disable_pipeline']
        queue.enqueue(self, priority: 1000000)
      end

      def perform
        retry_if_invalid
        command.call
      end

      private

      attr_reader :jobs, :command_class, :queue, :changes

      def retry_if_invalid
        return if @object.valid?
        new_object = @object.fetch
        raise "#{@object.name} noun with id=#{@object.id} is invalid" unless new_object.valid?
        @object = new_object
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
          changes: changes
        )
      end
    end
  end
end
