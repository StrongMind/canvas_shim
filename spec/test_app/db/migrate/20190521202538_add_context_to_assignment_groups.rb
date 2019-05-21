class AddContextToAssignmentGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :assignment_groups, :context_id, :integer
    add_column :assignment_groups, :context_type, :string
  end
end
