module PipelineService
  class PipelineClient
    attr_reader :message

    def initialize(args)
      @object     = args[:object]
      @noun       = args[:noun]
      @id         = args[:id]
      @args       = args
      @domain_name = ENV['CANVAS_DOMAIN']
      @endpoint_class   = args[:endpoint] || Endpoints::Pipeline
      @serializer_fetcher = args[:serializer_fetcher] || Serializers::Fetcher
      @serializer = args[:serializer]
      @logger = args[:logger] || PipelineService::Logger
    end

    def call
      fetch_serializer
      build_message
      post
      log
      self
    end

    private

    attr_reader :domain_name, :object, :noun, :id, :endpoint_class, :args, :serializer_fetcher, :serializer, :logger

    def log
      logger.new(message).call
    end

    def fetch_serializer
      return if @serializer
      @serializer = serializer_fetcher.fetch(object: object)
    end

    def post
      endpoint_class.new(
        message: message,
        args: args
      ).call
    end

    def build_message
      @message = {
          noun:        noun,
          domain_name: domain_name,
          id:          id,
          data:        serializer.new(object: object).call,
          meta:        { changes: object.changes }
        }
    end
  end
end
