class AddWorkflowStateToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :workflow_state, :string
  end
end
