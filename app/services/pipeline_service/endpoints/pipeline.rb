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
          Delayed::Job.enqueue(self, {strand: "pipeline_service", max_attempts: 100})
        end
        self
      end

      def perform
        configure_publisher
        build_payload
        post
      end

      private

      attr_reader :endpoint, :username, :password, :publisher, :message_builder, :payload

      def build_payload
        @payload = message_builder.new(@args).call
      end

      def self.http_client
        PipelinePublisher::MessagesApi.new
      end

      def configure_dependencies
        @message_builder = @args[:message_builder] || MessageBuilder
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
        byebug
        self.class.http_client.messages_post(payload)
      end
    end
  end
end
