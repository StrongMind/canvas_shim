class AddUserIdToDiscussionEntry < ActiveRecord::Migration[5.0]
  def change
    add_column :discussion_entries, :user_id, :int
  end
end
