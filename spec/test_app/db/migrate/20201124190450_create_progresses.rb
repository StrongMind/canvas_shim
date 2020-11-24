class CreateProgresses < ActiveRecord::Migration[5.0]
  def change
    create_table :progresses do |t|
      t.string :tag
      t.string :workflow_state
      t.integer :course_id
      t.float :completion
    end
  end
end
