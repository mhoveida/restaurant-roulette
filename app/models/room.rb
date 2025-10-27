class Room < ApplicationRecord
  # Preference validations
  validates :location, presence: true
  validates :price, presence: true, inclusion: { in: [ "$", "$$", "$$$", "$$$$" ] }
  validates :owner_name, presence: true
  # Cuisine preferences are optional

  # Code validations (but we'll generate it automatically)
  validates :code, presence: true, uniqueness: true

  serialize :categories, coder: JSON

  # Generate a 4-digit room code before creating
  before_validation :generate_code, on: :create

  private

  def generate_code
    return if code.present?

    self.code = loop do
      new_code = rand(1000..9999).to_s
      break new_code unless Room.exists?(code: new_code)
    end
  end
end
