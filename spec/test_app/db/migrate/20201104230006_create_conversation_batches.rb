class CreateConversationBatches < ActiveRecord::Migration[5.0]
  def change
    create_table :conversation_batches do |t|
      t.string :conversation_message_ids
      t.string :workflow_state
    end
  end
end
