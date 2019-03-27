class AddUpdatedAtToModels < ActiveRecord::Migration[5.0]
  def change
    ['assignments', 'conversations', 'enrollments', 'submissions', 'users'].each do |table|
      add_column table, :updated_at, :datetime
    end
  end
end
