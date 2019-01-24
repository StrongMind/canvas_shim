class AddUserIdToContextModuleProgressions < ActiveRecord::Migration[5.0]
  def change
    add_column :context_module_progressions, :user_id, :integer
  end
end
