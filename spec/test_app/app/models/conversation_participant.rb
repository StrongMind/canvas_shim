class ConversationParticipant < ApplicationRecord
  after_save { PipelineService.publish(self) }
end
