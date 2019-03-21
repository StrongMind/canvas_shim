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
        post_to_pipeline
        publish_events
        self
      end

      private

      attr_reader :object, :client, :responder, :changes

      def configure_dependencies
        @client     = @args[:client] || PipelineClient
      end

      def publish_events
        Commands::PublishEvents.new(@args).call
      end

      def post_to_pipeline
        client.new(@args.merge(object: object)).call
      end
    end
  end
end
