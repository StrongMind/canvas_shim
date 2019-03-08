class AddCachedDueDateToSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :cached_due_date, :datetime
  end
end
