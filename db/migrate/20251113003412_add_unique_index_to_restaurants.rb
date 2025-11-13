class AddUniqueIndexToRestaurants < ActiveRecord::Migration[8.1]
  def change
    add_index :restaurants, :id, unique: true
  end
end