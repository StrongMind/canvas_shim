module PipelineService
  # PipelineClient builds a pipeline message using the object
  # posts it to the endpoint and logs the message that was sent.
  #
  # Accepts an ActiveRecord object or a hash.  If using a hash, you must provide
  # a noun as an optional parameter
  #
  # PipelineCient.new(object: Enrollment.last)
  # PipelineCient.new(object: { data: { foo: 'bar' } }, noun: 'enrollment' )
  class PipelineClient
    def initialize(args)
      @args = args
      @object = args[:object]
      configure_dependencies
    end

    def call
      fetch_enrollment_from_hash
      post
      self
    end

    private

    attr_reader :endpoint, :object

    def configure_dependencies
      @endpoint = @args[:endpoint] || Endpoints::Pipeline
    end

    # EVIL!  I'm rewriting an arg.  What could go wrong?
    def fetch_enrollment_from_hash
      return unless object.is_a?(Hash)
      @args[:object] = Enrollment.find(object[:id])
    end

    def post
      endpoint.new(@args).call
    end
  end
end
