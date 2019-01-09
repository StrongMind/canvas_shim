class CreateDiscussionTopics < ActiveRecord::Migration[5.0]
  def change
    create_table :discussion_topics do |t|
      t.integer :context_id
      t.string :context_type
    end
  end
end
