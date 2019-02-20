class AddGradedAtToSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :graded_at, :datetime
  end
end
