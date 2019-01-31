class ConversationMessage < ApplicationRecord
  belongs_to :author, :class_name => 'User'
  after_save { PipelineService.publish(self) }

    belongs_to :conversation
    belongs_to :author, :class_name => 'User'
    # delegate :participants, :to => :conversation

end

# class ConversationMessage < ActiveRecord::Base
#   after_save { PipelineService.publish(self) }
#
#   belongs_to :conversation
#   belongs_to :author, :class_name => 'User'
#   belongs_to :context, polymorphic: [:account]
#   has_many :conversation_message_participants
#   has_many :attachment_associations, :as => :context, :inverse_of => :context
#   # we used to attach submission comments to conversations via this asset
#   # TODO: remove this column when we're sure we don't want this relation anymore
#   belongs_to :asset, polymorphic: [:submission]
#   delegate :participants, :to => :conversation
# end
