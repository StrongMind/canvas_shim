class AddContextModuleProgressionToContextModule < ActiveRecord::Migration[5.0]
  def change
    add_column :context_modules, :context_module_progression_id, :integer
  end
end
