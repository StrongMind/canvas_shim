class CreateDiscussionEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :discussion_entries do |t|
      t.integer :discussion_topic_id
    end
  end
end
