class Conversation < ActiveRecord::Base
  has_many :conversation_participants, :dependent => :destroy
  has_many :conversation_messages, -> { order("created_at DESC, id DESC") }, dependent: :delete_all
  has_many :conversation_message_participants, :through => :conversation_messages
end
