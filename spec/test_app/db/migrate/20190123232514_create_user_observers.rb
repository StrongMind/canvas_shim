class CreateUserObservers < ActiveRecord::Migration[5.0]
  def change
    create_table :user_observers do |t|
      t.integer   "user_id",                                       null: false
      t.integer   "observer_id"
    end
  end
end
