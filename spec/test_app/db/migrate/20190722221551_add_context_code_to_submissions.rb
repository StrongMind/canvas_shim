class AddContextCodeToSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :context_code, :string
  end
end
