class CreateConversationParticipants < ActiveRecord::Migration[5.0]
  def change
    create_table :conversation_participants do |t|

      t.timestamps
    end
  end
end
