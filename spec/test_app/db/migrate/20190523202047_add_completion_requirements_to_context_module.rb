class AddCompletionRequirementsToContextModule < ActiveRecord::Migration[5.0]
  def change
    add_column :context_modules, :completion_requirements, :text
  end
end
