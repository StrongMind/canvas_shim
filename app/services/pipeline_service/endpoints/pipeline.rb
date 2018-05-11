module PipelineService
  module Endpoints
    class Pipeline

      def initialize(args={})
        @args = args
        configure_dependencies
        raise 'Missing config' if missing_config?
      end

      def call
        if ENV['SYNCHRONOUS_PIPELINE_JOBS']
          perform
        else
          Delayed::Job.enqueue(self)
        end
        self
      end

      def perform
        configure_publisher
        build_payload
        post
      end

      private

      attr_reader :http_client, :endpoint, :username, :password, :publisher, :message_builder, :payload

      def build_payload
        @payload = message_builder.new(@args).call
      end

      def configure_dependencies
        @message_builder = @args[:message_builder] || MessageBuilder
        @http_client = @args[:http_client] || PipelinePublisher::MessagesApi
        @publisher   = @args[:publisher] || PipelinePublisher
        @endpoint    = ENV['PIPELINE_ENDPOINT']
        @username    = ENV['PIPELINE_USER_NAME']
        @password    = ENV['PIPELINE_PASSWORD']
      end

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
        http_client.new.messages_post(payload)
      end
    end
  end
end
