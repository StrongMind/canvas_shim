class AddWorkflowStateToContextModules < ActiveRecord::Migration[5.0]
  def change
    add_column :context_modules, :workflow_state, :string
  end
end
