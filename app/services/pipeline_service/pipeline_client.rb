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
    end

    def call
      fetch_serializer
      build_message
      post
      self
    end

    private

    attr_reader :domain_name, :object, :noun, :id, :endpoint_class, :args, :serializer_fetcher, :serializer

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
