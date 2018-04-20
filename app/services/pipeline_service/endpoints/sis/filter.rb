module PipelineService
  module Endpoints
    class SIS
      class Filter
        DATA_FILTER =  { state: 'completed' }
        NOUN_FILTER = 'student_enrollment'

        def initialize(message:)
          @message = message
        end

        def match?
          matches_noun_filter? && matches_data_filter?
        end

        private

        attr_reader :message

        def matches_noun_filter?
          message[:noun] == NOUN_FILTER
        end

        def matches_data_filter?
          DATA_FILTER.all? do |field, value|
            message[:data][field] == value
          end
        end
      end
    end
  end
end
