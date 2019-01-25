class AddTypeToEnrollments < ActiveRecord::Migration[5.0]
  def change
    add_column :enrollments, :type, :string
  end
end
