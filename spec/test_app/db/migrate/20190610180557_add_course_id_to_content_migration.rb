class AddCourseIdToContentMigration < ActiveRecord::Migration[5.0]
  def change
    add_column :content_migrations, :course_id, :integer
  end
end
