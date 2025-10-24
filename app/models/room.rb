class Room < ApplicationRecord
  # RULE 1: A code must be present
  validates :code, presence: true

  # RULE 2: A code must be unique
  validates :code, uniqueness: true
end
