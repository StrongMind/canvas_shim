module PipelineService
  class PipelineClient
    class HTTParty
      def self.post(one, two)
      end
    end

    attr_reader :message

    def initialize(args)
      @object            = args[:object]
      @noun_name         = args[:noun_name]
      @id                = args[:id]
      @endpoint          = ENV['PIPELINE_ENDPOINT']
      @username          = ENV['PIPELINE_USER_NAME']
      @password          = ENV['PIPELINE_PASSWORD']
      @domain_name       = ENV['CANVAS_DOMAIN']
      @args = args

      raise 'Missing environment variables' if config_missing?

      @publisher       = args[:publisher] || PipelinePublisher
      @api_instance    = args[:message_api] || PipelinePublisher::MessagesApi.new
      @message_builder_class = args[:message_builder_class] || MessageBuilder
      @sis_endpoint = (
        args[:sis_endpoint] ||
        PipelineService::PipelineClient::SISEndpoint
      ).new(message)
    end

    def call
      configure_publisher
      build_pipeline_message
      post
      self
    end

    private

    attr_reader :endpoint, :username, :password, :domain_name, :publisher,
      :api_instance, :serializer, :message_builder_class, :object, :noun_name,
      :id, :sis_endpoint

    def post
      api_instance.messages_post(message)
      sis_endpoint.call
    end
    handle_asynchronously :post unless ENV['PIPELINE_SKIP_QUEUE']

    def build_pipeline_message
      @message = message_builder_class.new(
        noun: noun_name,
        domain_name: domain_name,
        id: id,
        data: object
      ).build
    end

    def configure_publisher
      publisher.configure do |config|
        config.host     = endpoint
        config.username = username
        config.password = password
      end
    end

    def config_missing?
      [endpoint, username, password].any?(&:nil?)
    end
  end
end
