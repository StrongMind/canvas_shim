class CreateUserNotes < ActiveRecord::Migration[5.0]
  def change
    create_table :user_notes do |t|
      t.integer :user_id
      t.text :note
      t.integer :created_by_id

      t.timestamps
    end
  end
end
