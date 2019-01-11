class AddAssignmentIdToContentTags < ActiveRecord::Migration[5.0]
  def change
    add_column :content_tags, :assignment_id, :integer
    add_column :content_tags, :position, :integer
  end
end
