class AddSpinResultToRooms < ActiveRecord::Migration[8.1]
  def change
    add_column :rooms, :spin_result, :json
  end
end
