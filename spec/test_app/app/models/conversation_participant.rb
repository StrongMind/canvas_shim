class ConversationParticipant < ApplicationRecord
  belongs_to :conversation
  after_save { PipelineService.publish(self) }
end
