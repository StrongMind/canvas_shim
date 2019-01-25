class AddAssocUserIdToEnrollments < ActiveRecord::Migration[5.0]
  def change
    add_column :enrollments, :associated_user_id, :integer
  end
end
