class AddFieldsToContextModules < ActiveRecord::Migration[5.0]
  def change
    add_column :context_modules, :context_id, :integer
    add_column :context_modules, :context_type, :string
    add_column :context_modules, :name, :string

  end
end
