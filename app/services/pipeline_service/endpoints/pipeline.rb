module PipelineService
  module Endpoints
    class Pipeline
      def initialize(message, args={})
        @message = message
        @message_builder_class = args[:message_builder_class] || MessageBuilder
        @http_client = args[:http_client] || PipelinePublisher::MessagesApi
        @publisher   = args[:publisher] || PipelinePublisher
        @endpoint    = ENV['PIPELINE_ENDPOINT']
        @username    = ENV['PIPELINE_USER_NAME']
        @password    = ENV['PIPELINE_PASSWORD']
        @args        = args
        raise 'Missing config' if missing_config?
      end

      def call
        Delayed::Job.enqueue(self)
      end

      def peform
        post
      end

      private

      attr_reader :message, :args

      attr_reader :http_client, :message, :message_builder_class, :endpoint,
        :username, :password, :publisher

      def missing_config?
        [endpoint, username, password].any?(&:nil?)
      end

      def configure_publisher
        publisher.configure do |config|
          config.host     = endpoint
          config.username = username
          config.password = password
        end
      end

      def post
        http_client.new.messages_post(
          message_builder_class.new(message).build
        )
      end
    end
  end
end
