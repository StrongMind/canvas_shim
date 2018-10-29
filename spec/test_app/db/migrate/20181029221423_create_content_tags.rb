class CreateContentTags < ActiveRecord::Migration[5.0]
  def change
    create_table :content_tags do |t|
      t.integer :context_module_id
      t.integer :content_id
      t.string :content_type
    end
  end
end
