class ConversationParticipant < ApplicationRecord
  after_save { PipelineService.publish(self) }

  belongs_to :conversation
  # belongs_to :user
end
