module PipelineService
    module Nouns
      class ConversationAPIEnrollment < Base
        
        def initialize(ar_conversation)
          super(ar_conversation)
        end
        
        private 
  
        def builder
          Builder
        end
      end
    end
  end