class AddAccountAndIntegrationIdsToPseudonyms < ActiveRecord::Migration[5.0]
  def change
    add_column :pseudonyms, :account_id, :int
    add_column :pseudonyms, :integration_id, :string
  end
end
