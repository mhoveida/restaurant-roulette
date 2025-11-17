class AddHiddenSpinsToRooms < ActiveRecord::Migration[7.2]
  def change
    # Room state management
    add_column :rooms, :state, :integer, default: 0, null: false
    # States: 0=waiting, 1=spinning, 2=revealing, 3=voting, 4=complete
    
    # Turn tracking
    add_column :rooms, :current_round, :integer, default: 0
    add_column :rooms, :current_turn_index, :integer, default: 0
    add_column :rooms, :turn_order, :text  # JSON array of member IDs
    
    # Spins storage (hidden until revealed)
    add_column :rooms, :spins, :text  # JSON array of spin objects
    
    # Reveal order
    add_column :rooms, :reveal_order, :text  # JSON array of indices for random order
    
    # Voting
    add_column :rooms, :votes, :text  # JSON hash of member_id => option_index
    
    # Winner
    add_column :rooms, :winner, :text  # JSON object with winner details
    
    # Add index for faster state queries
    add_index :rooms, :state
  end
end
