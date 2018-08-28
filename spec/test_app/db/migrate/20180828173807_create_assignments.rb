class CreateAssignments < ActiveRecord::Migration[5.0]
  def change
    create_table :assignments do |t|
      t.datetime :due_at
      t.boolean :published
    end

  end
end
