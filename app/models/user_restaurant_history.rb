class UserRestaurantHistory < ApplicationRecord
  belongs_to :user
  belongs_to :restaurant

  validates :user_id, presence: true
  validates :restaurant_id, presence: true
  validates :restaurant_id, uniqueness: { scope: :user_id, message: "can only be saved once per user" }

  scope :recent, -> { order(created_at: :desc) }
end
