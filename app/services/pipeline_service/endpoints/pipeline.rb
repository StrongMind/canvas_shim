module PipelineService
  module Endpoints
    class Pipeline
      def initialize(args={})
        @args = args
        configure_dependencies
        raise 'Missing config: PIPELINE_ENDPOINT or PIPELINE_USER_NAME or PIPELINE_PASSWORD is nil' if missing_config?
      end

      def call
        return if SettingsService.get_settings(object: :school, id: 1)['disable_pipeline']
        Delayed::Job.enqueue(self, priority: 1000000)
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
        
        Logger.new(source: 'pipeline', message: @payload).call
        
        @payload
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
          if endpoint.slice(0,7) == 'http://'
            config.scheme = 'http'
          end
        end
      end

      def post
        PipelineService::HTTPClient.post(payload)
      end
    end
  end
end
