module PipelineService
  module Nouns
    class ConversationParticipant      
      class Builder
        def initialize object:
          @conversation_participant = object
        end

        def call
          @payload = Builders::ConversationParticipantJSONBuilder.call(conversation_participant)
        end

        private

        attr_reader :conversation_participant
      end
    end
  end
end
