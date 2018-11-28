class CreateSubmissionVersions < ActiveRecord::Migration[5.0]
  def change
    create_table :submission_versions do |t|
      t.text :yaml
      t.integer :submission_id
    end
  end
end
