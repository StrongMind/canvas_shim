class AddConcludeAtToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :conclude_at, :datetime
  end
end
