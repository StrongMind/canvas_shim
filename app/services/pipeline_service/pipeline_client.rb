module PipelineService
  class PipelineClient
    SOURCE = 'canvas'

    attr_reader :message

    def initialize(args)
      @object            = args[:object]
      @noun_name         = args[:noun_name]
      @host              = ENV['PIPELINE_ENDPOINT']
      @username          = ENV['PIPELINE_USER_NAME']
      @password          = ENV['PIPELINE_PASSWORD']
      @domain_name       = ENV['CANVAS_DOMAIN']

      raise 'Missing environment variables' if config_missing?

      @publisher       = args[:publisher] || PipelinePublisher
      @api_instance    = args[:message_api] || PipelinePublisher::MessagesApi.new
      @message_builder = args[:message_builder] || publisher::Message
    end

    def call
      configure_publisher
      build_pipeline_message
      post
      self
    end

    private

    attr_reader :host, :username, :password, :domain_name, :publisher,
      :api_instance, :payload, :serializer, :message_builder, :object,
      :noun_name

    def post
      api_instance.messages_post(message)
    end

    def build_pipeline_message
      @message = message_builder.new(
        noun: noun_name,
        meta: {
          source: SOURCE,
          domain_name: domain_name
        },
        identifiers: { id: object[:id] },
        data: payload
      )
    end

    def configure_publisher
      publisher.configure do |config|
        config.host     = host
        config.username = username
        config.password = password
      end
    end

    def config_missing?
      [@host, @username, @password].any?(&:nil?)
    end
  end
end
