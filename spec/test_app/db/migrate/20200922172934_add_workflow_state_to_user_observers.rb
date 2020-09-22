class AddWorkflowStateToUserObservers < ActiveRecord::Migration[5.0]
  def change
    add_column :user_observers, :workflow_state, :string
  end
end
