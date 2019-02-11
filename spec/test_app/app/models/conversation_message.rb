class ConversationMessage < ApplicationRecord
  belongs_to :author, :class_name => 'User'
  belongs_to :conversation
  belongs_to :author, :class_name => 'User'

  after_commit { PipelineService.publish(self) }
end
