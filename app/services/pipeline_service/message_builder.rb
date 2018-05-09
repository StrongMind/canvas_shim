module PipelineService
  class MessageBuilder
    SOURCE = 'canvas'

    def initialize(args)
      @id            = args[:id]
      @noun          = args[:noun]
      @object        = args[:data]
      @serializer    = args[:serializer]
      @args          = args
      configure_dependencies
    end

    def call
      fetch_serializer
      build
    end

    private

    attr_reader :message_class, :noun, :id, :object, :fetcher, :serializer, :canvas_domain

    def configure_dependencies
      @message_class = @args[:message_class] || PipelinePublisher::Message
      @fetcher       = @args[:fetcher] || Serializers::Fetcher
      @canvas_domain = ENV['CANVAS_DOMAIN']
    end

    def fetch_serializer
      return if @serializer
      @serializer = fetcher.fetch(object: object)
    end

    def build
      message_class.new(
        noun: noun,
        meta: {
          source: SOURCE,
          domain_name: canvas_domain
        },
        identifiers: { id: id },
        data: object
      )
    end
  end
end
