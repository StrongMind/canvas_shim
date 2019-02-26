module PipelineService
    module Nouns
      class User < Base
        ADDITIONAL_IDENTIFIER_FIELDS = [:assignment_id]
        
        def initialize(ar_user)
          super(ar_user)
        end
        
        private 
  
        def builder
          Builder
        end
      end
    end
  end