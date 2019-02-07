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
          @serialized_object = serializer_instance.call
        end

        def serializer_instance
          serializer.new(object: object)
        end

        def log
          Logger.new(source: 'pipeline', message: payload).call
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
            identifiers: { id: id }.merge(additional_identifiers),
            data: data
          }
        end

        def additional_identifiers
          return {} unless serializer_instance.respond_to?(:additional_identifiers)

          serializer_instance.additional_identifiers
        end

        def configure_dependencies
          @fetcher       = @args[:fetcher] || Serializers::Fetcher
          @logger        = @args[:logger] || PipelineService::Logger
          @canvas_domain = ENV['CANVAS_DOMAIN']
        end

        def data
          return {} if object.try(:state) == :deleted || object.try(:workflow_state) == 'deleted'
          serialized_object
        end

        def fetch_serializer
          return if @serializer
          @serializer = fetcher.fetch(object: object)
        end

        def build
          payload.to_hash
        end

        def noun
          object.class.to_s.split('::').last.underscore
        end

        def id
          return object.id unless object.is_a?(Hash)
          object[:id]
        end
      end
    end
  end
end
