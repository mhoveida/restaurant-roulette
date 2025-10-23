require 'rails_helper'

RSpec.describe Room, type: :model do
  # TEST FOR RULE 1:
  # This test tries to break the "presence" rule.
  it "is not valid without a code" do
    room = Room.new(code: nil)
    expect(room).not_to be_valid
  end

  # TEST FOR RULE 2:
  # This test tries to break the "uniqueness" rule.
  it "is not valid with a duplicate code" do
    FactoryBot.create(:room, code: "1234")
    room2 = Room.new(code: "1234")
    expect(room2).not_to be_valid
  end
end
