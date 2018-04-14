module PipelineService
  module Endpoints
    class Pipeline
      def initialize(object, args={})
        @object = object
        @id                = args[:id]
        @endpoint          = ENV['PIPELINE_ENDPOINT']
        @username          = ENV['PIPELINE_USER_NAME']
        @password          = ENV['PIPELINE_PASSWORD']
        @publisher         = args[:publisher] || PipelinePublisher
        @http_client       = args[:http_client] || PipelinePublisher::MessagesApi.new
        @message_builder_class = args[:message_builder_class] || MessageBuilder
        @domain_name       = ENV['CANVAS_DOMAIN']
      end

      def call
        raise 'Missing config' if missing_config?
        configure
        build_message
        post
      end

      private

      attr_reader :message, :http_client, :endpoint, :username, :password, :publisher, :object, :message_builder_class, :domain_name, :id

      def build_message
        @message = message_builder_class.new(
          noun:        noun_name,
          domain_name: domain_name,
          id:          id,
          data:        object
        ).build
      end

      def noun_name
        object.class.to_s.underscore
      end

      def missing_config?
        [endpoint, username, password].any?(&:nil?)
      end

      def post
        http_client.messages_post(message)
      end

      def configure
        publisher.configure do |config|
          config.host     = endpoint
          config.username = username
          config.password = password
        end
      end
    end
  end
end
