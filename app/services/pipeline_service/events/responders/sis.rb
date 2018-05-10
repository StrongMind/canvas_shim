module PipelineService
  module Events
    module Responders
      class SIS
        def initialize(message:, args: {})
          @message = message
          @args = args
          configure_dependencies
        end

        def call
          raise 'Missing config' if missing_config?
          post
          log
        end

        private

        attr_reader :message, :api_key, :endpoint, :args, :queue, :logger

        def configure_dependencies
          @api_key = ENV['SIS_ENROLLMENT_UPDATE_API_KEY']
          @endpoint = ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT']
          @queue = args[:queue] || Delayed::Job
          @logger = args[:logger] || PipelineService::Logger
        end

        def missing_config?
          [@api_key, @endpoint].any?(&:nil?)
        end

        def log
          logger.new(
            {
              source: 'pipeline_event::graded_out',
              message: message[:data],
              enpdoint: build_endpoint
            }
          ).call
        end

        def build_endpoint
          endpoint + '?apiKey=' + api_key
        end

        def post
          return unless message

          if ENV['SYNCHRONOUS_PIPELINE_JOBS']
             PostJob.new(build_endpoint, message[:data], args).peform
          else
            queue.enqueue PostJob.new(build_endpoint, message[:data], args)
          end
        end
      end
    end
  end
end
