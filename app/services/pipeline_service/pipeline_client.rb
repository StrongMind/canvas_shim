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
    end

    def call
      build_message
      post
      self
    end

    private

    attr_reader :domain_name, :object, :noun, :id, :endpoint_class, :args

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
          data:        object
        }
    end
  end
end
