class AddWorkflowStateToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :workflow_state, :string
  end
end
