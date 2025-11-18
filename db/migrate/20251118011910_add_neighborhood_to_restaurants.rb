class AddNeighborhoodToRestaurants < ActiveRecord::Migration[8.1]
  def change
    add_column :restaurants, :neighborhood, :string
  end
end
