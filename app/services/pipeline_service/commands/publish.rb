module PipelineService
  module Commands
    # Serialize a canvas object into their API format and
    # send to the pipeline
    #
    # Usage:
    # Send.new(message: User.last).call
    class Publish
      attr_reader :message, :persisted_message, :serializer

      def initialize(args)
        @args       = args
        @object     = args[:object]
        @client     = (args[:client] || PipelineClient)
        @serializer ||= args[:serializer]
        @serializer_fetcher = args[:serializer_fetcher] || SerializerFetcher
      end

      def call
        lookup_serializer
        post
        self
      end

      private

      attr_reader :object, :client, :args, :serializer_fetcher

      def lookup_serializer
        return if serializer
        @serializer = serializer_fetcher.fetch(object: object)
      end

      def config_client
        args.merge(
          object: serializer.new(object: object).call,
          noun: noun,
          id: object.id
        )
      end

      def post
        @message = client.new(config_client).call.message
      end

      def noun
        object.class.to_s.underscore
      end
    end
  end
end
