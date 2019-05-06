class AddEnrollmentIdToScores < ActiveRecord::Migration[5.0]
  def change
    add_column :scores, :enrollment_id, :integer
  end
end
