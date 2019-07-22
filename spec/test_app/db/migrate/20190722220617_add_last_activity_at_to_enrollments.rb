class AddLastActivityAtToEnrollments < ActiveRecord::Migration[5.0]
  def change
    add_column :enrollments, :last_activity_at, :datetime
  end
end
