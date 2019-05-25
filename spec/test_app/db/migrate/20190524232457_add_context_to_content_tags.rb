class AddContextToContentTags < ActiveRecord::Migration[5.0]
  def change
    add_column :content_tags, :context_id, :int
    add_column :content_tags, :context_type, :string
  end
end
