class AddUserIdToSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :user_id, :integer
  end
end
