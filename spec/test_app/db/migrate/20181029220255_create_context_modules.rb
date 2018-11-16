class CreateContextModules < ActiveRecord::Migration[5.0]
  def change
    create_table :context_modules do |t|
      t.integer :course_id
    end
  end
end
