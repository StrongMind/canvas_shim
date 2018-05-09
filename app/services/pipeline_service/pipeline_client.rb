module PipelineService
  # PipelineClient builds a pipeline message using the object, an optional noun
  # and an id, posts it to the endpoint and logs the message that was sent.
  #
  # Accepts an ActiveRecord object or a hash.  If using a hash, you must provide
  # a noun as an optional parameter
  #
  # PipelineCient.new(object: Enrollment.last)
  # PipelineCient.new(object: { data: { foo: 'bar' } }, noun: 'enrollment' )
  class PipelineClient
    attr_reader :message

    def initialize(args)
      @args   = args
      @noun   = args[:noun]
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

    attr_reader :noun, :endpoint, :logger, :message_builder

    def configure_dependencies
      @endpoint        = @args[:endpoint] || Endpoints::Pipeline
      @logger          = @args[:logger] || PipelineService::Logger
      @message_builder = @args[:message_builder] || PipelineService::Endpoints::Pipeline::MessageBuilder
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
