class AddCommentToSubmissionComments < ActiveRecord::Migration[5.0]
  def change
    add_column :submission_comments, :comment, :string
  end
end
