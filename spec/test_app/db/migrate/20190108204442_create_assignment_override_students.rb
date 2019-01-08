class CreateAssignmentOverrideStudents < ActiveRecord::Migration[5.0]
  def change
    create_table :assignment_override_students do |t|
      t.integer :assignment_id
      t.integer :assignment_override_id
      t.integer :user_id
    end
  end
end
