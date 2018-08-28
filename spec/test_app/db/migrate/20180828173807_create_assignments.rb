class CreateAssignments < ActiveRecord::Migration[5.0]
  def change
    create_table :assignments do |t|
      t.datetime :due_at
      t.boolean :published
      t.integer :context_id
    end

  end
end
