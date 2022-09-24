class AddCollapsedToContextModuleProgressionDecorator < ActiveRecord::Migration[5.0]
  def change
    add_column :context_module_progressions, :collapsed, :boolean
  end
end
