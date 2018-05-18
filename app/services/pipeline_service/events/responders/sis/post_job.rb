module PipelineService
  module Events
    module Responders
      class SIS
        class PostJob
          HEADERS = { 'Content-Type' => 'application/json' }
          PORT    = 8080
          def initialize(endpoint, data, args={})
            @endpoint    = endpoint
            @data        = data
            @args        = args
            configure_dependencies
          end

          def perform
            post
            log
          end

          private

          attr_reader :endpoint, :data, :logger

          def configure_dependencies
            @logger = @args[:logger] || PipelineService::Logger
          end

          def post
            PipelineService::Events::HTTPClient.post(
              endpoint,
              body:    data.to_json,
              headers: HEADERS
            )
          end

          def log
            logger.new(data).call
          end
        end
      end
    end
  end
end
