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
        @client     = @args[:client] || PipelineClient
      end

      def call
        return if disabled?
        post_to_pipeline
        publish_events
        self
      end

      private

      attr_reader :object, :client, :responder, :changes

      def disabled?
        SettingsService.get_settings(object: :school, id: 1)['disable_pipeline']
      end

      def publish_events
        return if changes.nil?
        Commands::PublishEvents.new(@args).call
      end

      def post_to_pipeline
        client.new(@args.merge(object: object)).call
      end
    end
  end
end
