class ConversationMessage < ApplicationRecord
  belongs_to :author, :class_name => 'User'
  belongs_to :conversation
  belongs_to :author, :class_name => 'User'
end
