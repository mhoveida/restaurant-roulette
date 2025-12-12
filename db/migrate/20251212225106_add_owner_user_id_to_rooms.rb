class AddOwnerUserIdToRooms < ActiveRecord::Migration[8.1]
  def change
    add_column :rooms, :owner_user_id, :integer
  end
end
