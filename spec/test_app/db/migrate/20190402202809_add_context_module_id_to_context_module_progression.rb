class AddContextModuleIdToContextModuleProgression < ActiveRecord::Migration[5.0]
  def change
    add_column :context_module_progressions, :context_module_id, :integer
  end
end
