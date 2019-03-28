class CreateSubmissionComments < ActiveRecord::Migration[5.0]
  def change
    create_table :submission_comments do |t|
      t.integer :submission_id
    end
  end
end
