class AddDietaryRestrictionsToRestaurants < ActiveRecord::Migration[8.1]
  def change
    add_column :restaurants, :dietary_restrictions, :text
  end
end
