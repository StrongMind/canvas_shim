class AddPublishedGradeAndScoreToSubmission < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :published_grade, :string
    add_column :submissions, :published_score, :float
  end
end
