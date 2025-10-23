class CreateRestaurants < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurants do |t|
      t.string :name, null: false
      t.decimal :rating, precision: 2, scale: 1
      t.string :price
      t.text :address
      t.string :phone
      t.string :image_url
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.integer :review_count, default: 0
      t.boolean :is_open_now, default: true
      t.json :categories

      t.timestamps
    end

    add_index :restaurants, :name
    add_index :restaurants, :price
    add_index :restaurants, :rating
  end
end
