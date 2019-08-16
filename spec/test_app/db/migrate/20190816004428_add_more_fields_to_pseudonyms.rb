class AddMoreFieldsToPseudonyms < ActiveRecord::Migration[5.0]
  def change
    add_column :pseudonyms,  :crypted_password, :string
    add_column :pseudonyms,  :password_salt, :string
    add_column :pseudonyms,  :persistence_token, :string
    add_column :pseudonyms,  :single_access_token, :string
    add_column :pseudonyms,  :perishable_token, :string
    add_column :pseudonyms,  :created_at, :timestamp
    add_column :pseudonyms,  :last_login_at, :timestamp
  end
end
