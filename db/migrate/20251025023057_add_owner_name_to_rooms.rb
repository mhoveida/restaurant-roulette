class AddOwnerNameToRooms < ActiveRecord::Migration[8.1]
  def change
    add_column :rooms, :owner_name, :string
  end
end
