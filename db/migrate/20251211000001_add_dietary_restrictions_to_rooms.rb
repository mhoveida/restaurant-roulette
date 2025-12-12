class AddDietaryRestrictionsToRooms < ActiveRecord::Migration[8.1]
  def change
    add_column :rooms, :dietary_restrictions, :jsonb, default: []
  end
end
