class CreateUserRestaurantHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :user_restaurant_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      t.datetime :visited_at

      t.timestamps
    end

    add_index :user_restaurant_histories, [ :user_id, :restaurant_id ], unique: true
  end
end
