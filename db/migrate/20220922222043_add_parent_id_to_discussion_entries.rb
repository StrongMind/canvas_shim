class AddParentIdToDiscussionEntries < ActiveRecord::Migration[5.0]
  def change
    add_column :discussion_entries, :parent_id, :integer
  end
end
