class CreateContextExternalTools < ActiveRecord::Migration[5.0]
  def change
    create_table :context_external_tools do |t|
      t.string :domain
    end
  end
end
