class AddCurrentScoreToScores < ActiveRecord::Migration[5.0]
  def change
    add_column :scores, :current_score, :integer
  end
end
