require 'rails_helper'

RSpec.describe Room, type: :model do
  let(:restaurant) { create(:restaurant) }

  # Validations
  describe 'validations' do
    it "is not valid without a code" do
      room = Room.new(code: nil)
      expect(room).not_to be_valid
    end

    it "is not valid without a location" do
      room = Room.new(owner_name: "John", price: "$$", code: "1234")
      expect(room).not_to be_valid
    end

    it "is not valid without a price" do
      room = Room.new(owner_name: "John", location: "NYC", code: "1234")
      expect(room).not_to be_valid
    end

    it "is not valid without owner_name" do
      room = Room.new(location: "NYC", price: "$$", code: "1234")
      expect(room).not_to be_valid
    end

    it "auto-generates a code" do
      room = Room.new(owner_name: "John", location: "NYC", price: "$$")
      room.valid?
      expect(room.code).to be_present
      expect(room.code).to match(/^\d{4}$/)
    end
  end

  # State enum
  describe 'state enum' do
    it 'has waiting state' do
      room = create(:room)
      expect(room.state).to eq('waiting')
      expect(room.waiting?).to be true
    end
    
    it 'has spinning state' do
      room = create(:room)
      room.update!(state: :spinning)
      expect(room.spinning?).to be true
    end
    
    it 'has revealing state' do
      room = create(:room)
      room.update!(state: :revealing)
      expect(room.revealing?).to be true
    end
    
    it 'has voting state' do
      room = create(:room)
      room.update!(state: :voting)
      expect(room.voting?).to be true
    end
    
    it 'has complete state' do
      room = create(:room)
      room.update!(state: :complete)
      expect(room.complete?).to be true
    end
  end

  # Member management
  describe '#add_guest_member' do
    let(:room) { create(:room) }

    it 'adds a guest member' do
      expect {
        room.add_guest_member("Alex")
      }.to change { room.reload.get_all_members.length }.by(1)
    end

    it 'accepts optional location' do
      room.add_guest_member("Alex", location: "Brooklyn")
      member = room.reload.get_all_members.find { |m| m[:name] == "Alex" }
      expect(member).to be_present
    end
    
    it 'accepts optional price' do
      room.add_guest_member("Alex", price: "$$$")
      member = room.reload.get_all_members.find { |m| m[:name] == "Alex" }
      expect(member).to be_present
    end
    
    it 'accepts optional categories' do
      room.add_guest_member("Alex", categories: ["Italian"])
      member = room.reload.get_all_members.find { |m| m[:name] == "Alex" }
      expect(member).to be_present
    end
    
    it 'accepts optional member_id' do
      room.add_guest_member("Alex", member_id: "custom_id")
      member = room.reload.get_member_by_id("custom_id")
      expect(member[:name]).to eq("Alex")
    end
    
    it 'generates member_id if not provided' do
      result = room.add_guest_member("Alex")
      expect(result["id"]).to match(/^guest_/)
    end
  end

  describe '#get_all_members' do
    let(:room) { create(:room, owner_name: "Owner") }

    it 'returns host as first member' do
      members = room.get_all_members
      expect(members.first[:name]).to eq("Owner")
      expect(members.first[:type]).to eq("host")
    end

    it 'includes guest members' do
      room.add_guest_member("Alex")
      members = room.get_all_members
      expect(members.length).to eq(2)
    end
  end

  describe '#get_member_by_id' do
    let(:room) { create(:room) }
    
    it 'returns owner member' do
      member = room.get_member_by_id("owner")
      expect(member[:name]).to eq(room.owner_name)
      expect(member[:type]).to eq("host")
    end
    
    it 'returns guest member' do
      room.add_guest_member("Alex", member_id: "guest_123")
      member = room.get_member_by_id("guest_123")
      expect(member[:name]).to eq("Alex")
    end
    
    it 'returns nil for non-existent member' do
      member = room.get_member_by_id("nonexistent")
      expect(member).to be_nil
    end
  end

  # Spinning phase
  describe '#start_spinning!' do
    let(:room) { create(:room) }
    
    it 'transitions to spinning state' do
      room.start_spinning!
      expect(room.spinning?).to be true
    end
    
    it 'initializes turn_order' do
      room.start_spinning!
      expect(room.turn_order).to eq(["owner"])
    end
    
    it 'sets current_round to 1' do
      room.start_spinning!
      expect(room.current_round).to eq(1)
    end
    
    it 'sets current_turn_index to 0' do
      room.start_spinning!
      expect(room.current_turn_index).to eq(0)
    end
    
    it 'initializes empty spins array' do
      room.start_spinning!
      expect(room.spins).to eq([])
    end
    
    it 'includes guests in turn_order' do
      room.add_guest_member("Alex")
      room.start_spinning!
      expect(room.turn_order.length).to eq(2)
    end
    
    it 'returns false if not in waiting state' do
      room.update!(state: :spinning)
      result = room.start_spinning!
      expect(result).to be false
    end
  end

  describe '#current_turn_member_id' do
    it 'returns current member id' do
      room = create(:room)
      room.update!(state: :spinning, turn_order: ["owner", "guest1"], current_turn_index: 1)
      expect(room.current_turn_member_id).to eq("guest1")
    end
    
    it 'returns nil if not spinning' do
      room = create(:room)
      expect(room.current_turn_member_id).to be_nil
    end
  end

  describe '#current_turn_member' do
    it 'returns current member' do
      room = create(:room)
      room.update!(state: :spinning, turn_order: ["owner"], current_turn_index: 0)
      member = room.current_turn_member
      expect(member[:name]).to eq(room.owner_name)
    end
  end

  describe '#is_my_turn?' do
    let(:room) { create(:room) }
    
    before do
      room.update!(state: :spinning, turn_order: ["owner", "guest1"], current_turn_index: 0)
    end
    
    it 'returns true for current member' do
      expect(room.is_my_turn?("owner")).to be true
    end
    
    it 'returns false for other member' do
      expect(room.is_my_turn?("guest1")).to be false
    end
    
    it 'returns false if not spinning' do
      room.update!(state: :waiting)
      expect(room.is_my_turn?("owner")).to be false
    end
  end

  describe '#spin_for_member' do
    let(:room) { create(:room) }
    
    before do
      room.update!(state: :spinning, turn_order: ["owner"], current_turn_index: 0, current_round: 1)
      allow(room).to receive(:find_random_restaurant).and_return({
        restaurant: restaurant,
        match_type: "exact"
      })
    end
    
    it 'adds spin to room' do
      expect {
        room.spin_for_member("owner")
      }.to change { room.reload.spins.length }.by(1)
    end
    
    it 'includes restaurant data' do
      room.spin_for_member("owner")
      spin = room.reload.spins.last
      expect(spin["restaurant"]).to be_present
    end
    
    it 'includes member_id' do
      room.spin_for_member("owner")
      spin = room.reload.spins.last
      expect(spin["member_id"]).to eq("owner")
    end
    
    it 'includes match_type' do
      room.spin_for_member("owner")
      spin = room.reload.spins.last
      expect(spin["match_type"]).to eq("exact")
    end
    
    it 'returns error if not your turn' do
      result = room.spin_for_member("wrong_member")
      expect(result[:success]).to be false
      expect(result[:error]).to be_present
    end
    
    it 'transitions to revealing when round complete' do
      room.spin_for_member("owner")
      expect(room.reload.revealing?).to be true
    end
  end

  describe '#advance_turn!' do
    it 'increments turn index' do
      room = create(:room)
      room.update!(state: :spinning, turn_order: ["owner", "guest1"], current_turn_index: 0)
      room.advance_turn!
      expect(room.current_turn_index).to eq(1)
    end
    
    it 'transitions to revealing when round complete' do
      room = create(:room)
      room.update!(state: :spinning, turn_order: ["owner"], current_turn_index: 0)
      room.advance_turn!
      expect(room.revealing?).to be true
    end
  end

  describe '#round_complete?' do
    it 'returns true when revealing' do
      room = create(:room)
      room.update!(state: :revealing)
      expect(room.round_complete?).to be true
    end
    
    it 'returns true when voting' do
      room = create(:room)
      room.update!(state: :voting)
      expect(room.round_complete?).to be true
    end
    
    it 'returns false when spinning' do
      room = create(:room)
      room.update!(state: :spinning)
      expect(room.round_complete?).to be false
    end
  end

  # Revealing phase
  describe '#reveal_options!' do
    let(:room) { create(:room) }
    
    before do
      room.update!(
        state: :revealing,
        spins: [
          {"member_id" => "owner", "restaurant" => {"name" => "Test1"}, "round" => 1},
          {"member_id" => "guest1", "restaurant" => {"name" => "Test2"}, "round" => 1}
        ],
        current_round: 1
      )
    end
    
    it 'transitions to voting state' do
      room.reveal_options!
      expect(room.voting?).to be true
    end
    
    it 'marks spins as revealed' do
      room.reveal_options!
      revealed_spin = room.reload.spins.find { |s| s["round"] == 1 }
      expect(revealed_spin["revealed"]).to be true
    end
    
    it 'initializes votes hash' do
      room.reveal_options!
      expect(room.votes).to eq({})
    end
    
    it 'sets reveal_order' do
      room.reveal_options!
      expect(room.reveal_order).to be_an(Array)
    end
    
    it 'returns false if not in revealing state' do
      room.update!(state: :waiting)
      result = room.reveal_options!
      expect(result).to be false
    end
  end

  describe '#get_revealed_spins' do
    it 'returns only revealed spins' do
      room = create(:room)
      room.update!(spins: [
        {"revealed" => true, "restaurant" => {"name" => "Test1"}},
        {"revealed" => false, "restaurant" => {"name" => "Test2"}}
      ])
      
      revealed = room.get_revealed_spins
      expect(revealed.length).to eq(1)
    end
  end

  # Voting phase
  describe '#vote' do
    let(:room) { create(:room) }
    
    before do
      room.update!(
        state: :voting,
        spins: [{
          "member_id" => "owner",
          "restaurant" => {"name" => "Test"},
          "round" => 1,
          "revealed" => true
        }],
        current_round: 1,
        reveal_order: [0]
      )
      room.reload
    end
    
    it 'records vote' do
      room.vote("owner", 0)
      room.reload
      expect(room.votes["owner"]).to be_present
    end
    
    it 'stores option_index' do
      room.vote("owner", 0)
      room.reload
      expect(room.votes["owner"]["option_index"]).to eq(0)
    end
    
    it 'marks as not confirmed' do
      room.vote("owner", 0)
      room.reload
      expect(room.votes["owner"]["confirmed"]).to be false
    end
    
    it 'returns false if not voting' do
      room.update!(state: :waiting)
      result = room.vote("owner", 0)
      expect(result).to be false
    end
    
    it 'returns false for invalid option_index' do
      result = room.vote("owner", 999)
      expect(result).to be false
    end
  end

  describe '#confirm_vote' do
    let(:room) { create(:room) }
    
    before do
      room.update!(
        state: :voting,
        spins: [{
          "member_id" => "owner",
          "restaurant" => {"name" => "Test"},
          "round" => 1,
          "revealed" => true
        }],
        current_round: 1,
        reveal_order: [0]
      )
      room.reload
      room.vote("owner", 0)
    end
    
    it 'marks vote as confirmed' do
      room.confirm_vote("owner")
      room.reload
      expect(room.votes["owner"]["confirmed"]).to be true
    end
    
    it 'calls check_voting_complete without error' do
      expect { room.confirm_vote("owner") }.not_to raise_error
    end
    
    it 'returns false if member has not voted' do
      result = room.confirm_vote("guest1")
      expect(result).to be false
    end
  end

  describe '#has_voted?' do
    let(:room) { create(:room) }
    
    it 'returns false when not voted' do
      expect(room.has_voted?("owner")).to be false
    end
    
    it 'returns true when voted' do
      room.update!(votes: {"owner" => {"option_index" => 0}})
      expect(room.has_voted?("owner")).to be true
    end
  end

  describe '#has_confirmed_vote?' do
    let(:room) { create(:room) }
    
    it 'returns false when not confirmed' do
      room.update!(votes: {"owner" => {"option_index" => 0, "confirmed" => false}})
      expect(room.has_confirmed_vote?("owner")).to be false
    end
    
    it 'returns true when confirmed' do
      room.update!(votes: {"owner" => {"option_index" => 0, "confirmed" => true}})
      expect(room.has_confirmed_vote?("owner")).to be true
    end
  end

  describe '#tally_votes_and_select_winner!' do
    let(:room) { create(:room) }
    
    before do
      # Properly setup with reveal_options! to ensure reveal_order is set
      room.update!(
        state: :revealing,
        turn_order: ["owner"],
        spins: [{"member_id" => "owner", "restaurant" => {"name" => "Test"}, "round" => 1}],
        current_round: 1
      )
      room.reveal_options!
      room.reload
      room.vote("owner", 0)
      room.confirm_vote("owner")
    end
    
    it 'transitions to complete state' do
      room.tally_votes_and_select_winner!
      expect(room.complete?).to be true
    end
    
    it 'sets winner' do
      room.tally_votes_and_select_winner!
      room.reload
      expect(room.winner).to be_present
    end
    
    it 'includes vote count in winner' do
      room.tally_votes_and_select_winner!
      room.reload
      expect(room.winner["votes"]).to eq(1)
    end
    
    it 'handles ties' do
      room.add_guest_member("Guest1", member_id: "guest1")
      room.update!(turn_order: ["owner", "guest1"])
      room.vote("guest1", 0)
      room.confirm_vote("guest1")
      
      room.tally_votes_and_select_winner!
      room.reload
      expect(room.winner).to be_present
    end
    
    it 'returns false if not in voting state' do
      room.update!(state: :waiting)
      result = room.tally_votes_and_select_winner!
      expect(result).to be false
    end
  end

  describe '#get_vote_counts' do
    let(:room) { create(:room) }
    
    it 'returns vote counts by option' do
      room.update!(
        state: :voting,
        votes: {
          "owner" => {"option_index" => 0, "confirmed" => true},
          "guest1" => {"option_index" => 0, "confirmed" => true},
          "guest2" => {"option_index" => 1, "confirmed" => true}
        }
      )
      
      counts = room.get_vote_counts
      expect(counts[0]).to eq(2)
      expect(counts[1]).to eq(1)
    end
  end

  # New round
  describe '#start_new_round!' do
    let(:room) { create(:room) }
    
    before do
      room.update!(state: :complete)
    end
    
    it 'transitions to spinning state' do
      room.start_new_round!
      expect(room.spinning?).to be true
    end
    
    it 'increments current_round' do
      room.update!(current_round: 1)
      room.start_new_round!
      expect(room.current_round).to eq(2)
    end
    
    it 'resets spins' do
      room.update!(spins: [{"test" => "data"}])
      room.start_new_round!
      room.reload
      expect(room.spins).to eq([])
    end
    
    it 'resets votes' do
      room.update!(votes: {"owner" => {"option_index" => 0}})
      room.start_new_round!
      room.reload
      expect(room.votes).to eq({})
    end
  end

  # Initialization
  describe 'initialization' do
    it 'initializes with default state' do
      room = create(:room)
      expect(room.waiting?).to be true
    end
    
    it 'initializes members as empty array' do
      room = create(:room)
      expect(room.members).to eq([])
    end
    
    it 'initializes votes as empty hash' do
      room = create(:room)
      expect(room.votes).to eq({})
    end
    
    it 'initializes spins as empty array' do
      room = create(:room)
      expect(room.spins).to eq([])
    end
    
    it 'sets current_round to 0' do
      room = create(:room)
      expect(room.current_round).to eq(0)
    end
  end

  # find_random_restaurant private method
  describe '#find_random_restaurant' do
    let(:room) { create(:room) }
    
    it 'tries exact match first' do
      expect(room).to receive(:search_restaurants).with(
        location: "SoHo",
        price: "$$",
        categories: ["Italian"]
      ).and_return(restaurant)
      
      result = room.send(:find_random_restaurant,
        location: "SoHo",
        price: "$$",
        categories: ["Italian"]
      )
      
      expect(result[:match_type]).to eq("exact")
    end
    
    it 'falls back through match levels' do
      allow(room).to receive(:search_restaurants).and_return(nil)
      allow(Restaurant).to receive_message_chain(:order, :first).and_return(restaurant)
      
      result = room.send(:find_random_restaurant,
        location: "SoHo",
        price: "$$",
        categories: ["Italian"]
      )
      
      expect(result[:match_type]).to eq("random")
    end
  end
end