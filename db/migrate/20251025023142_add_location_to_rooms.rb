class AddLocationToRooms < ActiveRecord::Migration[8.1]
  def change
    add_column :rooms, :location, :string
  end
end
