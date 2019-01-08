class CreateCourses < ActiveRecord::Migration[5.0]
  def change
    create_table :courses do |t|
      t.datetime :start_at
      t.string :time_zone
      t.datetime :end_at
    end
  end
end
