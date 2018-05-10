module PipelineService
  module Commands
    # Serialize a canvas object into their API format and
    # send to the pipeline
    #
    # Usage:
    # Send.new(message: User.last).call
    class Publish
      NOUN_MISSING_ERROR = 'Noun must be specified if object is a hash.'
      attr_reader :message, :serializer

      def initialize(args)
        @args       = args
        @object     = args[:object]
        @noun       = args[:noun]
        configure_dependencies
        validate_noun_is_present_if_object_is_hash!
      end

      def call
        post_to_pipeline
        publish_events if object.respond_to?(:changes)
        self
      end

      private

      attr_reader :object, :client, :args, :responder, :changes

      def configure_dependencies
        @client     = @args[:client] || PipelineClient
        @responder  = @args[:responder] || Events::Responders::SIS
      end

      def validate_noun_is_present_if_object_is_hash!
        raise NOUN_MISSING_ERROR if object.is_a?(Hash) && @noun.nil?
      end

      def publish_events
        PublishEvents.new(
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
          args.merge(
            object: object,
            noun: noun,
            id: id
          )
        ).call
      end

      def noun
        @noun || object.class.to_s.underscore
      end

      def id
        return object.id unless object.is_a?(Hash)
        object[:id]
      end
    end
  end
end
