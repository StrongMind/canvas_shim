class AddWorkflowStateToContentMigration < ActiveRecord::Migration[5.0]
  def change
    add_column :content_migrations, :workflow_state, :string
  end
end
