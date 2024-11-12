class AddBodyToSubmissionDecorator < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :body, :text
  end
end
