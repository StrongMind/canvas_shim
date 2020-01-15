class AddContextToSubmissionComment < ActiveRecord::Migration[5.0]
  def change
    add_column :submission_comments, :context_id, :int
    add_column :submission_comments, :context_type, :string
  end
end
