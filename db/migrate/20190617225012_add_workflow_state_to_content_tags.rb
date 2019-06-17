class AddWorkflowStateToContentTags < ActiveRecord::Migration[5.0]
  def change
    add_column :content_tags, :workflow_state, :string
  end
end
