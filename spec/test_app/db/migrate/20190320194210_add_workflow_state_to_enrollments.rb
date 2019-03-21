class AddWorkflowStateToEnrollments < ActiveRecord::Migration[5.0]
  def change
    add_column :enrollments, :workflow_state, :string
  end
end
