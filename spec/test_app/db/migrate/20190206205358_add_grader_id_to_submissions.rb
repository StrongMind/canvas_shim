class AddGraderIdToSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :grader_id, :integer
  end
end
