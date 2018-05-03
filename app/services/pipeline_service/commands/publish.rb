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
        @client     = args[:client] || PipelineClient
        @responder   = args[:responder] || Events::Responders::SIS
      end

      def call
        post_to_pipeline
        publish_events
        self
      end

      private

      attr_reader :object, :client, :args, :responder

      def config_client
        args.merge(
          object: object,
          noun: noun,
          id: object.id
        )
      end

      def publish_events
        puts '*' * 1000, object.changes
        PublishEvents.new(
          message,
          changes: object.changes,
          subscriptions: [
            Events::Subscription.new(
              event: :graded_out,
              responder: responder.new(message: message)
            )
          ]
        ).call
      end

      def post_to_pipeline
        @message = client.new(config_client).call.message
      end

      def noun
        object.class.to_s.underscore
      end
    end
  end
end
