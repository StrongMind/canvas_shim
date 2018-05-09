module PipelineService
  class PipelineClient
    attr_reader :message

    def initialize(args)
      @args   = args
      @object = args[:object]
      @noun   = args[:noun]
      @id     = args[:id]
      @args   = args
      configure_dependencies
    end

    def call
      build_message
      post
      log
      self
    end

    private

    attr_reader :object, :noun, :id, :endpoint, :logger, :message_builder

    def configure_dependencies
      @endpoint        = @args[:endpoint] || Endpoints::Pipeline
      @logger          = @args[:logger] || PipelineService::Logger
      @message_builder = @args[:message_builder] || MessageBuilder
    end

    def log
      logger.new(
        { source: 'pipeline', message: message }
      ).call
    end

    def post
      endpoint.new(message, @args).call
    end

    def build_message
      @message = message_builder.new(@args).call
    end
  end
end
