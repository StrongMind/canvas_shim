module PipelineService
    module Nouns
      class Enrollment < Base
        def initialize(ar_enrollment)
          super(ar_enrollment)
        end
        
        private 
  
        def builder
          Builder
        end
      end
    end
  end