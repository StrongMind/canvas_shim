class AddAssignmentIdToDiscussionTopic < ActiveRecord::Migration[5.0]
  def change
    add_column :discussion_topics, :assignment_id, :integer
  end
end
