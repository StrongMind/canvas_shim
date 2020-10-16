class AddContextToContextExternalTools < ActiveRecord::Migration[5.0]
  def change
    add_column :context_external_tools, :context_id, :integer
    add_column :context_external_tools, :context_type, :string
    add_column :context_external_tools, :consumer_key, :string
    add_column :context_external_tools, :shared_secret, :string
  end
end
