module PipelineService
  module Commands
    # Serialize a canvas object into their API format and
    # send to the pipeline
    #
    # Usage:
    # Send.new(message: User.last).call
    class Publish
      attr_reader :message, :serializer

      def initialize(args)
        @args       = args
        @object     = args[:object]
        @changes    = args[:changes]
        configure_dependencies
      end

      def call
        return if SettingsService.get_settings(object: :school, id: 1)['disable_pipeline']
        return unless object.serializer
        post_to_pipeline
        self
      end

      private

      attr_reader :object, :client, :responder, :changes

      def configure_dependencies
        @client     = @args[:client] || PipelineClient
      end

      def post_to_pipeline
        if client == PipelineService::V2::Client
          client.publish(v1_message_payload)
        else
          client.new(publisher_arguments).call
        end
      end

      def v1_message_payload
        Endpoints::Pipeline::MessageBuilder.new(publisher_arguments).call
      end

      def publisher_arguments
        @args.merge(object: object)
      end
    end
  end
end
