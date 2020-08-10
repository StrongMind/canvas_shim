class CreateCommunicationChannels < ActiveRecord::Migration[5.0]
  def change
    create_table :communication_channels do |t|
      t.string :path
      t.string :path_type
      t.integer :user_id
    end
  end
end
