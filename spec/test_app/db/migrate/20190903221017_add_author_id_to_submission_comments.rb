class AddAuthorIdToSubmissionComments < ActiveRecord::Migration[5.0]
  def change
    add_column :submission_comments, :author_id, :bigint
  end
end
