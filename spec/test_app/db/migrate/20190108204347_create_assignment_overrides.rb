class CreateAssignmentOverrides < ActiveRecord::Migration[5.0]
  def change
    create_table :assignment_overrides do |t|
      t.integer :assignment_id
    end
  end
end
