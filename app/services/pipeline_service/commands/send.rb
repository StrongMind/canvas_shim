module PipelineService
  module Commands
    class Send
      attr_reader :message, :persisted_message

      def initialize(args)
        @serializer = args[:serializer] || EnrollmentSerializer.new(object: object)
        @object     = args[:object]
        @client     = args[:client] || PipelineClient.new(
          args.merge(object: serialize_object, noun_name: noun_name)
        )
      end

      # Send.call will serialize a canvas object into their API format and
      # send to the pipeline
      #
      # Usage:
      # Send.new(object: some_active_record_object)
      def call
        serialize_object
        post
        persist
        self
      end

      private

      attr_reader :payload, :object, :username, :password,
        :user, :api_instance, :payload, :publisher, :host,
        :serializer, :domain_name, :message_builder, :queue, :job,
        :message_type, :client

        def serialize_object
          @payload = serializer.call
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
