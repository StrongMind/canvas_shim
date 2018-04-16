module PipelineService
  class PipelineClient
    attr_reader :message

    def initialize(args)
      @object     = args[:object]
      @noun_name  = args[:noun_name]
      @id         = args[:id]
      @args       = args
      @endpoint   = args[:endpoint] || Endpoints::Pipeline.new(object, noun_name, id, args)
    end

    def call
      post
      self
    end

    private

    attr_reader :username, :password, :domain_name, :publisher,
      :api_instance, :serializer, :message_builder_class, :object, :noun_name,
      :id, :endpoint

    def post
      endpoint.call
    end
  end
end
