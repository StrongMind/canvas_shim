class AddFieldsAtToAssignmentOverrides < ActiveRecord::Migration[5.0]
  def change
    add_column :assignment_overrides, :due_at, :datetime
    add_column :assignment_overrides, :title, :string
  end
end
