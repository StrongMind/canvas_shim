class AddDueAtOverriddenToAssignmentOverrides < ActiveRecord::Migration[5.0]
  def change
    add_column :assignment_overrides, :due_at_overridden, :boolean
  end
end
