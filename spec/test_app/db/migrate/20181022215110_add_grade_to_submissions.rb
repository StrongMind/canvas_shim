class AddGradeToSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :grade, :integer
  end
end
