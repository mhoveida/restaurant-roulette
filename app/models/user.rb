class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  # Associations
  has_many :user_restaurant_histories, dependent: :destroy
  has_many :visited_restaurants, through: :user_restaurant_histories, source: :restaurant

  # Validations - only validate names on signup, not login
  validates :first_name, presence: true, on: :create
  validates :last_name, presence: true, on: :create

  # Custom validation for login context
  validate :validate_login_credentials, on: :login

  # Helper methods
  def full_name
    "#{first_name} #{last_name}".strip
  end

  def short_name
    first_name
  end

  # When a user signs in via Google, find or create them
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      full_name = auth.info.name || ""
      user.first_name = auth.info.first_name || full_name.split.first || "Google"
      user.last_name = auth.info.last_name || full_name.split.last || "User"
      user.password = Devise.friendly_token[0, 20]
    end
  end

  private

  def validate_login_credentials
    errors.add(:email, "is required") if email.blank?
    errors.add(:password, "is required") if password.blank?
  end
end
