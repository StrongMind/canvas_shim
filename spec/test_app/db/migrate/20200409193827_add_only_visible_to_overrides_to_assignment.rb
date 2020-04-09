class AddOnlyVisibleToOverridesToAssignment < ActiveRecord::Migration[5.0]
  def change
    add_column :assignments, :only_visible_to_overrides, :bool
  end
end
