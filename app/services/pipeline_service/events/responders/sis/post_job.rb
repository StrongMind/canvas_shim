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
            @http_client = args[:http_client] || HTTParty
            @logger = args[:logger]
          end

          def perform
            post
            log
          end

          private

          attr_reader :endpoint, :data, :http_client, :logger

          def post
            http_client.post(
              endpoint,
              body:    data.to_json,
              headers: HEADERS
            )
          end

          def log
            logger.new(data.to_json).call
          end
        end
      end
    end
  end
end
