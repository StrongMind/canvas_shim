class ConversationMessage < ApplicationRecord
  after_save { PipelineService.publish(self) }
end
