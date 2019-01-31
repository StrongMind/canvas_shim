class AddConversationIdToConversationParticipants < ActiveRecord::Migration[5.0]
  def change
    add_column :conversation_participants, :conversation_id, :integer
  end
end
