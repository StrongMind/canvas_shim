class AddCourseIdToContextExternalTools < ActiveRecord::Migration[5.0]
  def change
    add_column :context_external_tools, :course_id, :int
  end
end
