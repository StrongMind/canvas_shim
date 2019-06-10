class CreateContentMigration < ActiveRecord::Migration[5.0]
  def change
    create_table :content_migrations do |t|
      t.string :workflow_state
    end
  end
end
