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
  before_create :initialize_members

  def add_guest_member(guest_name)
    self.members ||= []
    self.members << { "name" => guest_name, "type" => "guest", "joined_at" => Time.current }
    save
  end

  def get_all_members
    members_list = [{ "name" => owner_name, "type" => "host", "joined_at" => created_at }]
    if members.present?
      members_list.concat(members)
    end
    members_list.map { |m| symbolize_keys(m) }
  end

  def spin_restaurant
    restaurant = RestaurantService.new.random_restaurant(
      location: location,
      categories: categories,
      price: price
    )

    if restaurant
      self.spin_result = restaurant
      save
      restaurant
    else
      nil
    end
  end

  private

  def symbolize_keys(hash)
    if hash.is_a?(Hash)
      hash.transform_keys(&:to_sym)
    else
      hash
    end
  end

  def generate_code
    return if code.present?

    self.code = loop do
      new_code = "%04d" % rand(0..9999).to_s
      break new_code unless Room.exists?(code: new_code)
    end
  end

  def initialize_members
    self.members = [] if members.nil?
  end
end
