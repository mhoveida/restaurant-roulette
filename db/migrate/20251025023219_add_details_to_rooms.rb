class AddDetailsToRooms < ActiveRecord::Migration[8.1]
  def change
    add_column :rooms, :price, :string
    add_column :rooms, :categories, :text
  end
end
