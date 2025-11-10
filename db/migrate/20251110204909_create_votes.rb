class CreateVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :votes do |t|
      t.references :room, null: false, foreign_key: true
      t.integer :restaurant_id, null: false
      t.string :voter_name, null: false
      t.string :value, null: false  # "up" or "down"

      t.timestamps
    end

    # Prevent duplicate votes by the same person for the same restaurant in a room
    add_index :votes, [:room_id, :restaurant_id, :voter_name], unique: true
  end
end
