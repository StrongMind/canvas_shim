class AddTimestamps < ActiveRecord::Migration[5.0]
  def change
	add_column :submissions, :created_at, :datetime
  end
end
