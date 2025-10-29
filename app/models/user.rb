class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

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

  private

  def validate_login_credentials
    errors.add(:email, "is required") if email.blank?
    errors.add(:password, "is required") if password.blank?
  end
end
