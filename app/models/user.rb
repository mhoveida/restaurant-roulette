class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  # Validations - only validate names on signup, not login
  validates :first_name, presence: true, on: :create
  validates :last_name, presence: true, on: :create
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Custom validation for login - check email and password are present
  validate :validate_login_credentials, on: :login

  # Helper methods
  def full_name
    "#{first_name} #{last_name}".strip
  end

  def short_name
    first_name
  end

  private

  def validate_login_credentials
    errors.add(:email, "is required") if email.blank?
    errors.add(:password, "is required") if password.blank?
  end
end
