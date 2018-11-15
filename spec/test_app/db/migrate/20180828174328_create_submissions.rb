class CreateSubmissions < ActiveRecord::Migration[5.0]
  def change
    create_table :submissions do |t|
      t.integer :assignment_id
      t.integer :score
      t.boolean :excused
      t.string :workflow_state
    end
  end
end
