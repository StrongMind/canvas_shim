module PipelineService
  module Endpoints
    class Pipeline
      class MessageBuilder
        SOURCE = 'canvas'

        def initialize(args)
          @object        = args[:object]
          @serializer    = args[:serializer]
          @args          = args
          configure_dependencies
        end

        def call
          fetch_serializer
          serialize
          result = build
          log
          result
        end

        private

        attr_reader :message_class, :object, :fetcher, :serializer, :canvas_domain, :logger, :serialized_object

        def serialize
          @serialized_object = serializer.new(object: object).call
        end

        def log
          logger.new(source: 'pipeline', message: payload).call
        end

        def payload
          {
            noun: noun,
            meta: {
              source: SOURCE,
              domain_name: canvas_domain,
              api_version: 1,
              status: object.try(:state)
            },
            identifiers: { id: id },
            data: serialized_object
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
          message_class.new(payload.to_hash)
        end

        def noun
          object.class.to_s.underscore
        end

        def id
          object.id unless object.is_a?(Hash)
          object[:id]
        end
      end
    end
  end
end
