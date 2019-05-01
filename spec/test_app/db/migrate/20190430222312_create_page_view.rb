class CreatePageView < ActiveRecord::Migration[5.0]
  def change
    create_table :page_views, id: false do |t|
       t.primary_key :request_id
    end
  end
end
