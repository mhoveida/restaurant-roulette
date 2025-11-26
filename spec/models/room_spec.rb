require 'rails_helper'

RSpec.describe Room, type: :model do
  # Validations - Code
  describe 'code validations' do
    it "is not valid without a code" do
      room = Room.new(code: nil)
      expect(room).not_to be_valid
    end

    it "is not valid with a duplicate code" do
      FactoryBot.create(:room, code: "1234")
      room2 = Room.new(code: "1234")
      expect(room2).not_to be_valid
    end

    it "auto-generates a code if not provided" do
      room = Room.new(owner_name: "John", location: "NYC", price: "$$")
      expect(room.code).to be_nil
      room.valid?
      expect(room.code).to be_present
      expect(room.code).to match(/^\d{4}$/)
    end

    it "generates unique codes" do
      room1 = FactoryBot.create(:room)
      room2 = FactoryBot.create(:room)
      expect(room1.code).not_to eq(room2.code)
    end
  end

  # Validations - Location
  describe 'location validations' do
    it "is not valid without a location" do
      room = Room.new(owner_name: "John", price: "$$", code: "1234")
      expect(room).not_to be_valid
      expect(room.errors[:location]).to include("Please enter a location")
    end

    it "is not valid with numbers in location" do
      room = Room.new(owner_name: "John", location: "NYC123", price: "$$", code: "1234")
      expect(room).not_to be_valid
      expect(room.errors[:location]).to include("Please enter a valid location")
    end

    it "is valid with location containing hyphens" do
      room = Room.new(owner_name: "John", location: "New-York", price: "$$", code: "1234")
      expect(room).to be_valid
    end

    it "is valid with spaces in location" do
      room = Room.new(owner_name: "John", location: "New York", price: "$$", code: "1234")
      expect(room).to be_valid
    end
  end

  # Validations - Price
  describe 'price validations' do
    it "is not valid without a price" do
      room = Room.new(owner_name: "John", location: "NYC", code: "1234")
      expect(room).not_to be_valid
      expect(room.errors[:price]).to include("Please select a price range")
    end

    it "is not valid with invalid price" do
      room = Room.new(owner_name: "John", location: "NYC", price: "$$$$$", code: "1234")
      expect(room).not_to be_valid
      expect(room.errors[:price]).to include("Please select a valid price range")
    end

    it "is valid with all valid price formats" do
      [ "$", "$$", "$$$", "$$$$" ].each do |price|
        room = Room.new(owner_name: "John", location: "NYC", price: price, code: "1234")
        expect(room).to be_valid
      end
    end
  end

  # Validations - Owner Name
  describe 'owner_name validations' do
    it "is not valid without owner name" do
      room = Room.new(location: "NYC", price: "$$", code: "1234")
      expect(room).not_to be_valid
      expect(room.errors[:owner_name]).to include("Please enter your name")
    end
  end

  # Methods
  describe '#add_guest_member' do
    let(:room) { FactoryBot.create(:room) }

    it "adds a guest member to the room" do
      expect {
        room.add_guest_member("Alex")
      }.to change { room.reload.get_all_members.length }.by(1)
    end

    it "sets the guest member type to 'guest'" do
      room.add_guest_member("Alex")
      member = room.reload.get_all_members.find { |m| (m[:name] || m["name"]) == "Alex" }
      expect(member[:type] || member["type"]).to eq("guest")
    end

    it "sets the guest member name correctly" do
      room.add_guest_member("Alex")
      member = room.reload.get_all_members.find { |m| (m[:name] || m["name"]) == "Alex" }
      expect(member[:name] || member["name"]).to eq("Alex")
    end

    it "records the joined_at timestamp" do
      room.add_guest_member("Alex")
      member = room.reload.get_all_members.find { |m| (m[:name] || m["name"]) == "Alex" }
      expect(member[:joined_at] || member["joined_at"]).to be_present
    end

    it "allows multiple guests to be added" do
      room.add_guest_member("Alex")
      room.add_guest_member("Jordan")
      members = room.reload.get_all_members
      expect(members.length).to eq(3) # owner + 2 guests
      names = members.map { |m| m[:name] || m["name"] }
      expect(names).to include("Alex", "Jordan")
    end
  end

  describe '#get_all_members' do
    let(:room) { FactoryBot.create(:room, owner_name: "Owner") }

    it "returns host as first member" do
      members = room.get_all_members
      expect(members.first[:name]).to eq("Owner")
      expect(members.first[:type]).to eq("host")
    end

    it "symbolizes keys in member hashes" do
      room.add_guest_member("Alex")
      members = room.get_all_members
      expect(members.last).to have_key(:name)
      expect(members.last).to have_key(:type)
      expect(members.last).to have_key(:joined_at)
    end

    it "includes guest members in the list" do
      room.add_guest_member("Alex")
      room.add_guest_member("Jordan")
      members = room.get_all_members
      expect(members.length).to eq(3)
      names = members.map { |m| m[:name] }
      expect(names).to include("Owner", "Alex", "Jordan")
    end

    it "includes joined_at timestamp for host" do
      members = room.get_all_members
      expect(members.first[:joined_at]).to eq(room.created_at)
    end
  end

  # REMOVED: spin_restaurant method no longer exists
  # The app now uses spin_for_member(member_id) instead
  
  describe 'categories serialization' do
    it "stores categories as JSON" do
      room = FactoryBot.create(:room, categories: [ "Italian", "French" ])
      expect(room.reload.categories).to eq([ "Italian", "French" ])
    end

    it "handles empty categories array" do
      room = FactoryBot.create(:room, categories: [])
      expect(room.reload.categories).to eq([])
    end
  end

  describe 'initialization' do
    it "initializes members as empty array" do
      room = FactoryBot.create(:room)
      expect(room.members).to eq([])
    end
  end
end