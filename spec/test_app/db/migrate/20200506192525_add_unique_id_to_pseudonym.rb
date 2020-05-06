class AddUniqueIdToPseudonym < ActiveRecord::Migration[5.0]
  def change
    add_column :pseudonyms, :unique_id, :string
  end
end
