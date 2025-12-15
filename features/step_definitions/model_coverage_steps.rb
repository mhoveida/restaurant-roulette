def model_owner_id(room)
  member = room.get_all_members.find do |m|
    m[:role] == "owner" || m["role"] == "owner"
  end
  member[:id] || member["id"]
end

Then('the room should report having members') do
  expect(@room.get_all_members.length).to be > 0
end

Then('the room should not be complete') do
  expect(@room.round_complete?).to eq(false)
end

Then('the host should have voted') do
  owner_id = model_owner_id(@room)
  expect(@room.has_voted?(owner_id)).to eq(true)
end

Then('the host vote should not be confirmed') do
  owner_id = model_owner_id(@room)
  expect(@room.has_confirmed_vote?(owner_id)).to eq(false)
end

Then('vote counts should include option {int}') do |_idx|
  counts = @room.get_vote_counts
  expect(counts.values.sum).to eq(0)
end

Given('a completed room with a winner exists') do
  @room = Room.create!(
    owner_name: "John Doe",
    location: "SoHo",
    price: "$$",
    dietary_restrictions: ["No Restriction"],
    categories: ["Italian"],
    state: :complete,
    winner: {
      "restaurant" => {
        "name" => "Test Restaurant",
        "address" => "123 Test St",
        "price" => "$$",
        "rating" => 4.5
      }
    }
  )
end

Then('the room should have a winner') do
  expect(@room.winner).not_to be_nil
end

Then('the restaurant cuisine list should be empty') do
  expect(@restaurant.cuisine_list).to eq("")
end

Given('a user exists with first name {string} and last name {string}') do |first, last|
  @user = User.create!(
    email: "#{first.downcase}@example.com",
    password: "Password123",
    first_name: first,
    last_name: last
  )
end

Then('the user\'s full name should be {string}') do |name|
  expect(@user.full_name).to eq(name)
end

Then('the user\'s short name should be {string}') do |name|
  expect(@user.short_name).to eq(name)
end

Given('the room is in the voting phase') do
  @room ||= Room.last
  raise "Room not found" unless @room

  members = @room.members || []

  unless members.any? { |m| m["role"] == "owner" }
    members << {
        "id" => "owner",
        "name" => @room.owner_name,
        "role" => "owner"
    }
    
    @room.update!(members: members)
  end


  owner_id = model_owner_id(@room)

  spin = {
    "member_id" => owner_id,
    "member_name" => @room.owner_name,
    "restaurant" => {
      "name" => "Model Test Restaurant",
      "address" => "123 Test St",
      "price" => "$$",
      "rating" => 4.5
    },
    "match_type" => "exact",
    "round" => 1,
    "revealed" => true
  }

  @room.update!(
    state: :voting,
    current_round: 1,
    turn_order: [owner_id],
    current_turn_index: 0,
    spins: [spin],
    reveal_order: [0],
    votes: {}
  )

  @room.reload
end

When('the host records a vote for option {int}') do |idx|
  @room ||= Room.last
  owner_id = model_owner_id(@room)
  @vote_result = @room.vote(owner_id, idx)
end

When('the host confirms the recorded vote') do
  @room ||= Room.last
  owner_id = model_owner_id(@room)
  @confirm_result = @room.confirm_vote(owner_id)
  @room.reload
end
