module PipelineService
    module Nouns
      class Assignment < Base
        ADDITIONAL_IDENTIFIER_FIELDS = [:course_id]
        
        def initialize(ar_assignment)
          super(ar_assignment)
        end
        
        private 
  
        def builder
          Builder
        end
      end
    end
  end