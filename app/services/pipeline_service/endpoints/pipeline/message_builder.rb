module PipelineService
  module Endpoints
    class Pipeline
      class MessageBuilder
        SOURCE = 'canvas'

        def initialize(args)
          @id            = args[:id]
          @noun          = args[:noun]
          @object        = args[:object]
          @serializer    = args[:serializer]
          @args          = args
          configure_dependencies
        end

        def call
          fetch_serializer
          result = build
          log
          result
        end

        private

        attr_reader :message_class, :noun, :id, :object, :fetcher, :serializer, :canvas_domain, :logger

        def log
          logger.new(
            { source: 'pipeline', message: payload }
          ).call
        end

        def payload
          {
            noun: noun,
            meta: {
              source: SOURCE,
              domain_name: canvas_domain
            },
            identifiers: { id: id },
            data: serializer.new(object: object).call
          }
        end

        def configure_dependencies
          @message_class = @args[:message_class] || PipelinePublisher::Message
          @fetcher       = @args[:fetcher] || Serializers::Fetcher
          @logger        = @args[:logger] || PipelineService::Logger
          @canvas_domain = ENV['CANVAS_DOMAIN']
        end

        def fetch_serializer
          return if @serializer
          @serializer = fetcher.fetch(object: object)
        end

        def build
          message_class.new(payload)
        end
      end
    end
  end
end
