module PipelineService
  module Endpoints
    class Pipeline
      class MessageBuilder
        SOURCE = 'canvas'

        def initialize(args)
          @object        = args[:object]
          @args          = args
          @logger        = @args[:logger] || PipelineService::Logger
          @canvas_domain = ENV['CANVAS_DOMAIN']
        end

        def call
          serialize
          result = build
          log
          result
        end

        private

        attr_reader :message_class, :object, :canvas_domain, :logger, :json

        def serialize
          @json = object.as_json
        end

        def log
          logger.new(source: 'pipeline', message: payload).call
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
          json
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
