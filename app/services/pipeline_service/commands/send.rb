module PipelineService
  module Commands
    # Serialize a canvas object into their API format and
    # send to the pipeline
    #
    # Usage:
    # Send.new(object: some_active_record_object).call
    class Send
      attr_reader :message, :persisted_message, :serializer

      def initialize(args)
        @args       = args
        @object     = args[:object]
        @serializer = args[:serializer] || object.pipeline_serializer.new(object: object)
        @client     = args[:client] || PipelineClient.new(config_client)
        @logger     = args[:logger] || PipelineService::Logger
      end

      def call
        post
        # log
        self
      end

      private

      attr_reader :object, :client, :args, :logger

      def config_client
        args.merge(
          object: serializer.call,
          noun_name: noun_name,
          id: object.id
        )
      end

      def log
        logger.log(message)
      end

      def post
        @message = client.call.message
      end

      def noun_name
        object.class.to_s.underscore
      end
    end
  end
end
