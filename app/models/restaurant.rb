# app/models/restaurant.rb

class Restaurant < ApplicationRecord
  validates :name, presence: true
  validates :rating, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :price, presence: true,
            inclusion: { in: [ "$", "$$", "$$$", "$$$$" ] }
  validates :address, presence: true

  # serialize :categories, coder: JSON

  scope :by_cuisine, ->(cuisine) {
    where("categories LIKE ?", "%#{cuisine}%") if cuisine.present?
  }

  scope :by_price, ->(price) {
    where(price: price) if price.present?
  }

  scope :by_location, ->(location) { all }
  scope :open_now, -> { where(is_open_now: true) }

  def cuisine_list
  categories.is_a?(Array) ? categories.join(", ") : ""
end

  def has_cuisine?(cuisine)
    return false unless categories.is_a?(Array)
    categories.any? { |c| c.downcase.include?(cuisine.downcase) }
  end
end
