class CreateConversationBatches < ActiveRecord::Migration[5.0]
  def change
    create_table :conversation_batches do |t|
      t.string :conversation_message_ids
    end
  end
end
