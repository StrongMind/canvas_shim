class AddContextToContentMigrations < ActiveRecord::Migration[5.0]
  def change
    add_column :content_migrations, :context_id, :int
    add_column :content_migrations, :context_type, :string
  end
end
