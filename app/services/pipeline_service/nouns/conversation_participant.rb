module PipelineService
    module Nouns
      class ConversationParticipant < Base
        ADDITIONAL_IDENTIFIER_FIELDS = [:conversation_id]
        
        def initialize(ar_conversation_participant)
          super(ar_conversation_participant)
        end
  
        private 
  
        def builder
          Builder
        end
      end
    end
  end