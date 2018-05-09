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
    def initialize(args)
      @args = args
      configure_dependencies
    end

    def call
      post
      self
    end

    private

    attr_reader :endpoint

    def configure_dependencies
      @endpoint = @args[:endpoint] || Endpoints::Pipeline
    end

    def post
      endpoint.new(@args).call
    end
  end
end
