module PipelineService
  module Endpoints
    class Pipeline
      class MessageBuilder
        SOURCE = 'canvas'

        def initialize(args)
          @object        = args[:object]
          @serializer    = args[:serializer]
          @args          = args
          @logger        = @args[:logger] || PipelineService::Logger
          @canvas_domain = ENV['CANVAS_DOMAIN']
        end

        def call
          fetch_serializer
          serialize
          build
        end

        private

        attr_reader :message_class, :object, :serializer, :canvas_domain, :logger, :serialized_object

        def serialize
          @serialized_object = serializer_instance.call
        end

        def serializer_instance
          @serializer_instance ||= serializer.new(object: object)
        end

        def status
          @object.status
        end

        def payload
          {
            noun: noun_name,
            meta: {
              source: SOURCE,
              domain_name: canvas_domain,
              api_version: 1,
              status: status
            },
            identifiers: { id: object.id }.merge(additional_identifiers),
            data: data
          }
        end

        def additional_identifiers
          object.additional_identifiers
        end


        def data
          serialized_object
        end

        def fetch_serializer
          return if @serializer
          @serializer = object.serializer
        end

        def build
          payload.to_hash
        end

        def noun_name
          object.name
        end
      end
    end
  end
end
