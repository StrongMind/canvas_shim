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
        @listener   = args[:listener] || Events::Listeners::SIS
      end

      def call
        post_to_pipeline
        publish_events
        self
      end

      private

      attr_reader :object, :client, :args, :serializer_fetcher, :listener

      def config_client
        args.merge(
          object: object,
          noun: noun,
          id: object.id
        )
      end

      def publish_events
        PublishEvents.new(
          message,
          subscriptions: [
            Events::Subscription.new(event: :graded_out, listeners: listener.new(message: message))
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
