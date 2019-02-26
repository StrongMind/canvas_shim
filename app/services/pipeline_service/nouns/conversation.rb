module PipelineService
    module Nouns
      class Conversation < Base
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