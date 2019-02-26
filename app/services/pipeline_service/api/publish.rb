# The API calls Commands
#
# Class methods map to Commands
# ie: PipelineService::API::Publish calls PipelineService::Commands::Publish
#
module PipelineService
  module API
    class Publish
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

      # Perform method automatically gets called by the queue
      def perform
        command.call
      end

      private

      attr_reader :object, :jobs, :command_class, :queue, :changes

      def command
        command_class.new(
          object: object,
          changes: changes
        )
      end
    end
  end
end
