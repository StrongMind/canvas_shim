module PipelineService
  module Commands
    # Send will serialize a canvas object into their API format and
    # send to the pipeline
    #
    # Usage:
    # Send.new(object: some_active_record_object).call
    class Send
      attr_reader :message, :persisted_message

      def initialize(args)
        @args       = args
        @object     = args[:object]
        @serializer = args[:serializer] || EnrollmentSerializer.new(object: object)
        @client     = args[:client] || PipelineClient.new(config_client)
      end

      def call
        post
        persist
        self
      end

      private

      attr_reader :object, :serializer, :client, :args

      def config_client
        args.merge(
          object: serializer.call,
          noun_name: noun_name,
          id: object.id
        )
      end

      def persist
        @persisted_message = HashWithIndifferentAccess.new(
          JSON.parse(message.to_json)
        ).delete_blank.to_json

        HTTParty.post(
          "https://lrs.strongmind.com/pipeline-watcher-staging",
          body: persisted_message
        )
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
