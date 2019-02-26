class ConversationParticipant < ApplicationRecord
  belongs_to :conversation
  after_commit { 
    PipelineService.publish(self) 
  }
end
