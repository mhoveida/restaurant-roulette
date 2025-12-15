# features/step_definitions/rooms_controller_edge_steps.rb

#
# --- Spinning edge cases ---
#

When("the host attempts to start spinning again") do
  post start_spinning_room_path(@room)
end

Then("the start spinning request should fail") do
  expect(last_response.status).to eq(422)
end

Given("the room has already started spinning") do
  @room.start_spinning!
end

Given("the room is spinning") do
  @room.start_spinning!
end

When("the non current member attempts to spin") do
  post spin_room_path(@room), params: {
    member_id: "not_current_member"
  }
end

Then("the spin should fail") do
  expect(last_response.status).to eq(422)
end

#
# --- Reveal edge cases ---
#

When("the host attempts to reveal options early") do
  post reveal_room_path(@room)
end

Then("the reveal should fail") do
  expect(last_response.status).to eq(422)
end

#
# --- Voting edge cases ---
#

When("the host confirms a vote without voting") do
  post confirm_vote_room_path(@room), params: {
    member_id: "owner"
  }
end

Then("the confirmation should fail") do
  expect(last_response.status).to eq(422)
end

#
# --- New round edge case ---
#

When("the host attempts to start a new round early") do
  post new_round_room_path(@room)
end

Then("the new round request should fail") do
  expect(last_response.status).to eq(422)
end

#
# --- Completing a round ---
#

Given("the room has finished spinning and revealed options") do
  @room ||= Room.last
  raise "Room not found" unless @room

  owner_id = "owner"
  guest = @room.add_guest_member(
    "Guest User",
    categories: ["Italian"],
    dietary_restrictions: ["No Restriction"]
  )
  raise "Guest not found" unless guest
  guest_id = guest["id"]

  @room.update!(
    state: :voting,
    current_round: 1,
    turn_order: [owner_id, guest_id],
    current_turn_index: 0,
    spins: [
      {
        "member_id" => owner_id,
        "member_name" => "John Doe",
        "restaurant" => { "name" => "Option A" },
        "round" => 1,
        "revealed" => true
      },
      {
        "member_id" => guest_id,
        "member_name" => "Guest User",
        "restaurant" => { "name" => "Option B" },
        "round" => 1,
        "revealed" => true
      }
    ],
    reveal_order: [0, 1],
    votes: {}
  )
end

Given("the host session is established") do
  # No-op on purpose: identity is passed via params
end

When('the host submits a valid vote for option {int}') do |idx|
  get "/rooms/#{@room.id}?test_creator=true"
  post "/rooms/#{@room.id}/vote", params: {
    option_index: idx,
    test_creator: true
  }
end

When("the guest records a vote for option {int}") do |idx|
  guest = @room.members.last
  raise "Expected guest to be a Hash, got #{guest.class}" unless guest.is_a?(Hash)

  guest_id = guest["id"]

  post vote_room_path(@room),
       params: { option_index: idx },
       headers: { "rack.session" => { "member_id_for_room_#{@room.id}" => guest_id } }
end

When("the host finalizes their vote") do
  post confirm_vote_room_path(@room), params: { test_creator: true }
end

When("the guest confirms the recorded vote") do
  guest = @room.members.last
  raise "Expected guest to be a Hash, got #{guest.class}" unless guest.is_a?(Hash)

  guest_id = guest["id"]

  post confirm_vote_room_path(@room),
       params: {},
       headers: { "rack.session" => { "member_id_for_room_#{@room.id}" => guest_id } }
end

When("the client requests the room status") do
  get "/rooms/#{@room.id}/status"
end

Then("the confirmed vote count should be {int}") do |count|
  json = JSON.parse(last_response.body)
  expect(json["confirmed_votes_count"]).to eq(count)
end

#
# --- Guest join validation ---
#

When("a guest attempts to join room {string} with categories but no dietary restrictions") do |code|
  room = Room.find_by(code: code)
  raise "Room not found" unless room

  post "/rooms/#{room.id}/join_as_guest", params: {
    guest_name: "Guest User",
    location: "SoHo",
    price: "$$",
    categories: ["Italian"],
    dietary_restrictions: []
  }
end

Then('the guest should see an error asking to select a dietary option') do
  room = Room.last
  expect(room.members).to be_empty
end

And("voting is completed") do
  @room.reload

  members = @room.turn_order

  members.each_with_index do |member_id, idx|
    @room.votes ||= {}
    @room.votes[member_id.to_s] ||= {
      "option_index" => 0,
      "confirmed" => true
    }
  end

  @room.votes_will_change!
  @room.save!

  @room.tally_votes_and_select_winner!
end