class AddTagTypeToContentTags < ActiveRecord::Migration[5.0]
  def change
    add_column :content_tags, :tag_type, :string
  end
end
