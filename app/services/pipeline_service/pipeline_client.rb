module PipelineService
  class PipelineClient
    attr_reader :message

    def initialize(args)
      @object     = args[:object]
      @noun       = args[:noun]
      @id         = args[:id]
      @args       = args
      @domain_name = ENV['CANVAS_DOMAIN']
      @message_builder_class = args[:message_builder_class] || MessageBuilder
      @endpoint_class   = (args[:endpoint] || Endpoints::Pipeline)
    end

    def call
      build_message
      post
      self
    end

    private

    attr_reader :domain_name, :object, :noun, :id, :endpoint_class,
      :message_builder_class, :message, :args

    def post
      endpoint_class.new(
        message: message,
        noun: noun,
        id: id,
        args: args
      ).call
    end

    def build_message
      @message = message_builder_class.new(
        noun:        noun,
        domain_name: domain_name,
        id:          id,
        data:        object
      ).build
    end
  end
end
