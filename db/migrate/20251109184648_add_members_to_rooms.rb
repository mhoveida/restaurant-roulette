class AddMembersToRooms < ActiveRecord::Migration[8.1]
  def change
    add_column :rooms, :members, :json, default: []
  end
end
