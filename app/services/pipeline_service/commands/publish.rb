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
        configure_dependencies
      end

      def call
        post_to_pipeline
        publish_events if object.respond_to?(:changes)
        self
      end

      private

      attr_reader :object, :client, :responder, :changes

      def configure_dependencies
        @client     = @args[:client] || PipelineClient
        @responder  = @args[:responder] || Events::Responders::SIS
      end

      def publish_events
        Commands::PublishEvents.new(
          object,
          subscriptions: [
            Events::Subscription.new(
              event: :graded_out,
              responder: responder.new(message: message)
            )
          ]
        ).call
      end

      def subscription
        Events::Subscription.new(
          event: :graded_out,
          responder: responder.new(message: message)
        )
      end

      def post_to_pipeline
        client.new(
          @args.merge(object: object)
        ).call
      end
    end
  end
end
