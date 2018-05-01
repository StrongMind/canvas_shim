module PipelineService
  module Events
    module Responders
      class SIS
        def initialize(message:, args: {})
          @message = message
          @api_key = ENV['SIS_ENROLLMENT_UPDATE_API_KEY']
          @endpoint = ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT']
          @args = args
          @queue = args[:queue] || Delayed::Job
        end

        def call
          raise 'Missing config' if missing_config?
          post
        end

        private

        attr_reader :message, :api_key, :endpoint, :filter, :args, :queue

        def missing_config?
          [@api_key, @endpoint].any?(&:nil?)
        end

        def build_endpoint
          endpoint + '?apiKey=' + api_key
        end

        def post
          return unless message
          queue.enqueue PostJob.new(build_endpoint, message[:data], args)
        end
      end
    end
  end
end
