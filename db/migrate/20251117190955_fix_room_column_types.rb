class FixRoomColumnTypes < ActiveRecord::Migration[8.1]
  def change
    # Change all JSON columns from text to jsonb
    change_column :rooms, :members, :jsonb, default: [], using: 'members::jsonb'
    change_column :rooms, :turn_order, :jsonb, default: [], using: 'turn_order::jsonb'
    change_column :rooms, :spins, :jsonb, default: [], using: 'spins::jsonb'
    change_column :rooms, :votes, :jsonb, default: {}, using: 'votes::jsonb'
    change_column :rooms, :categories, :jsonb, default: [], using: 'categories::jsonb'
    change_column :rooms, :reveal_order, :jsonb, default: [], using: 'reveal_order::jsonb'
    change_column :rooms, :winner, :jsonb, using: 'winner::jsonb'
  end
end