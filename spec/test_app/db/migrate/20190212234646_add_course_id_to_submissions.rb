class AddCourseIdToSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :course_id, :integer
  end
end
