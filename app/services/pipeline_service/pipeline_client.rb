module PipelineService
  # PipelineClient builds a pipeline message using a Models::Noun
  # posts it to the endpoint and logs the message that was sent.
  #
  # Accepts an Noun
  #
  # PipelineCient.new(object: PipelineService::Models::Noun.new(Enrollment.last))
  
  class PipelineClient
    def initialize(args)
      @args = args
      @object = args[:object]
      configure_dependencies
    end

    def call
      post
      self
    end

    private

    attr_reader :endpoint, :object

    def configure_dependencies
      @endpoint = @args[:endpoint] || Endpoints::Pipeline
    end

    def post
      endpoint.new(@args).call
    end
  end
end
