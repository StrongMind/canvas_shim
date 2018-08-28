class CreateSubmissions < ActiveRecord::Migration[5.0]
  def change
    create_table :submissions do |t|
      t.string :assignment_id
      t.integer :score
      t.string :workflow_state
    end
  end
end
