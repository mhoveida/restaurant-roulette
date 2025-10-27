class Room < ApplicationRecord
  # Preference validations
  validates :location, 
            presence: { message: "Please enter a location" },
            format: { with: /\A[a-zA-Z\s\-]+\z/, message: "Please enter a valid location" }
  validates :price, 
            presence: { message: "Please select a price range" },
            inclusion: { in: [ "$", "$$", "$$$", "$$$$" ], message: "Please select a valid price range" }
  validates :owner_name, 
            presence: { message: "Please enter your name" }
  # Cuisine preferences are optional

  # Code validations (but we'll generate it automatically)
  validates :code, 
            presence: true, 
            uniqueness: true

  serialize :categories, coder: JSON

  # Generate a 4-digit room code before creating
  before_validation :generate_code, on: :create

  private

  def generate_code
    return if code.present?

    self.code = loop do
      new_code = "%04d" % rand(0..9999).to_s
      break new_code unless Room.exists?(code: new_code)
    end
  end
end
