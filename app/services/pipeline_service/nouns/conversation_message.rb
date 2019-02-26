module PipelineService
    module Nouns
      class ConversationMessage < Base
        ADDITIONAL_IDENTIFIER_FIELDS = [:conversation_id]
        
        def initialize(ar_conversation_message)
          super(ar_conversation_message)
        end
  
        private 
  
        def builder
          Builder
        end
      end
    end
  end