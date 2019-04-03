module PipelineService
  module Events
    module Responders
      class SIS
        HEADERS = { 'Content-Type' => 'application/json' }

        def initialize(object:, message:, args: {})
          @message = message
          @args = args
          configure_dependencies
        end

        def call
          raise 'Missing config: SIS_ENROLLMENT_UPDATE_API_KEY or SIS_ENROLLMENT_UPDATE_ENDPOINT is nil' if missing_config?
          queue.enqueue(self)
        end

        def perform
          post
          log
        end

        private

        attr_reader :message, :api_key, :endpoint, :args, :queue

        def configure_dependencies
          @api_key  = ENV['SIS_ENROLLMENT_UPDATE_API_KEY']
          @endpoint = ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT']
          @queue    = args[:queue] || Delayed::Job
        end

        def missing_config?
          [@api_key, @endpoint].any?(&:nil?)
        end

        def log
          PipelineService::Logger.new(
              source: 'pipeline_event::graded_out',
              message: message,
              enpdoint: build_endpoint
          ).call
        end

        def build_endpoint
          endpoint + '?apiKey=' + api_key
        end

        def post
          return unless message

          PipelineService::Events::HTTPClient.post(
            build_endpoint,
            body:    message.to_json,
            headers: HEADERS
          )
        end
      end
    end
  end
end
