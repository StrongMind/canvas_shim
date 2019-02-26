module PipelineService
  module Nouns
    class Submission < Base
      ADDITIONAL_IDENTIFIER_FIELDS = [:assignment_id]
      
      def initialize(ar_submission)
        super(ar_submission)
      end
      
      private 

      def builder
        Builder
      end
    end
  end
end