class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  # Validations - only validate names on signup, not login
  validates :first_name, presence: true, on: :create
  validates :last_name, presence: true, on: :create

  # Helper methods
  def full_name
    "#{first_name} #{last_name}".strip
  end

  def short_name
    first_name
  end
end
