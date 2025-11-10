class Vote < ApplicationRecord
  belongs_to :room

  validates :restaurant_id, :voter_name, :value, presence: true
  validates :value, inclusion: { in: %w[up down] }
end
