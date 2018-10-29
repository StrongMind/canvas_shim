class AddWorkflowStateToAssignments < ActiveRecord::Migration[5.0]
  def change
    add_column :assignments, :workflow_state, :string
  end
end
