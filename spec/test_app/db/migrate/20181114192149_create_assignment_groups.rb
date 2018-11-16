class CreateAssignmentGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :assignment_groups do |t|
      t.integer :course_id
      t.integer :group_weight
      t.string :name
    end
  end
end
