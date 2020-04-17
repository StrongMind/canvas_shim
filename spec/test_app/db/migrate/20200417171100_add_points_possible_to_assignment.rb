class AddPointsPossibleToAssignment < ActiveRecord::Migration[5.0]
  def change
    add_column :assignments, :points_possible, :float
  end
end
