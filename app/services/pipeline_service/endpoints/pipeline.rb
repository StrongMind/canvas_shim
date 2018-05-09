module PipelineService
  module Endpoints
    class Pipeline
      def initialize(message, args={})
        @message = message
        @args    = args
        configure_dependencies
        raise 'Missing config' if missing_config?
      end

      def call
        Delayed::Job.enqueue(self)
      end

      def perform
        configure_publisher
        post
      end

      private

      attr_reader :http_client, :message, :endpoint,
        :username, :password, :publisher

      def configure_dependencies
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
        http_client.new.messages_post(message)
      end
    end
  end
end
