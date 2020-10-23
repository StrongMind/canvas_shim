# The API calls Commands
#
# Class methods map to Commands
# ie: PipelineService::API::Publish calls PipelineService::Commands::Publish
module PipelineService
  module API
    class Publish
      attr_reader :object

      def initialize(object, args={})
        if object.is_a? PipelineService::Models::Noun
          @object = object
        else
          @object = Models::Noun.new(object, alias: args[:alias])
        end
        @changes = object.try(:changes)
        @command_class = args[:command_class] || Commands::Publish
        @queue         = args[:queue] || Delayed::Job
        @client = args[:client] || PipelineClient
      end

      def call
        return if SettingsService.get_settings(object: :school, id: 1)['disable_pipeline']
        if client.is_a?(PipelineService::V2::Client)
          queue.enqueue(self, priority: 1000000)
        else
          perform
        end
      end

      def perform
        retry_if_invalid unless object.valid?
        command.call
      end

      private

      attr_reader :jobs, :command_class, :queue, :changes, :client

      # If an object makes it here that is not valid, fetch it again and see if it is valid now.
      # Otherwise, raise an error to renqueue the command
      def retry_if_invalid
        @object = object.fetch
        return if object.valid?
        raise "#{object.name} noun with id=#{object.id} is invalid"
      end

      def command
        command_class.new(
          object: object,
          changes: changes
        )
      end
    end
  end
end
