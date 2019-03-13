class AddWorkflowStateToDiscussionTopics < ActiveRecord::Migration[5.0]
  def change
    add_column :discussion_topics, :workflow_state, :string
  end
end
