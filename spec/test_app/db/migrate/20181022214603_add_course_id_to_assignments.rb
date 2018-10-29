class AddCourseIdToAssignments < ActiveRecord::Migration[5.0]
  def change
    add_column :assignments, :course_id, :integer
  end
end
