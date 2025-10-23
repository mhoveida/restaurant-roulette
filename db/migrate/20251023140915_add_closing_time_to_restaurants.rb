class AddClosingTimeToRestaurants < ActiveRecord::Migration[8.1]
  def change
    add_column :restaurants, :closing_time, :string
  end
end
