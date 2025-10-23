class Room < ApplicationRecord
    validates :code, presence: true, uniqueness: true
end
