class AddUniqueIndexToVotes < ActiveRecord::Migration[8.1]
  def change
    add_index :votes, [:restaurant_id, :voter_name, :room_id],
              unique: true,
              name: "index_votes_on_restaurant_voter_room_unique"
  end
end
