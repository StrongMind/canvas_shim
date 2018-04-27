module PipelineService
  module Events
    module Responders
      class SIS
        def initialize(message:, args: {})
          @message = message
          @api_key = ENV['SIS_ENROLLMENT_UPDATE_API_KEY']
          @endpoint = ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT']
          @args = args
        end

        def call
          raise 'Missing config' if missing_config?
          post
        end

        private

        attr_reader :message, :api_key, :endpoint, :filter, :args

        def missing_config?
          [@api_key, @endpoint].any?(&:nil?)
        end

        def build_endpoint
          # endpoint + '?apiKey=' + api_key
          'http://echo:8080/postback/canvas/EnrollmentUpdate'
        end

        def post
          return unless message
          # Delayed::Job.enqueue
          PostJob.new(build_endpoint, message[:data], args).perform
        end
      end
    end
  end
end
