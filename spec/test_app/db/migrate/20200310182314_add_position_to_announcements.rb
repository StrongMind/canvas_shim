class AddPositionToAnnouncements < ActiveRecord::Migration[5.0]
  def change
    add_column :announcements, :position, :int
  end
end
