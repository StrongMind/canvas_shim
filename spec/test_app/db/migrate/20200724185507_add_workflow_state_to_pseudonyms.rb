class AddWorkflowStateToPseudonyms < ActiveRecord::Migration[5.0]
  def change
    add_column :pseudonyms, :workflow_state, :string
  end
end
