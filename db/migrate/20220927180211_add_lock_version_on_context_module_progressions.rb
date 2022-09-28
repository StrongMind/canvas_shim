class AddLockVersionOnContextModuleProgressions < ActiveRecord::Migration[5.0]
  def self.up
    add_column :context_module_progressions, :lock_version, :integer
    change_column_default :context_module_progressions, :lock_version, 0
  end

  def self.down
    remove_column :context_module_progressions, :lock_version
  end
end
