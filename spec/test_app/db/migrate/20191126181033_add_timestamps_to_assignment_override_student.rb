class AddTimestampsToAssignmentOverrideStudent < ActiveRecord::Migration[5.0]
  def change
    add_column :assignment_override_students, :created_at, :datetime
    add_column :assignment_override_students, :updated_at, :datetime
  end
end
