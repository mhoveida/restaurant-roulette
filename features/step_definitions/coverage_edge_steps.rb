def owner_member_id(room)
  # Try to find explicit owner member
  member = room.get_all_members.find do |m|
    m[:role] == "owner" || m["role"] == "owner"
  end

  # Fallback: owner always has ID "owner"
  member ? (member[:id] || member["id"]) : "owner"
end

When('an invalid member tries to spin') do
  @room ||= Room.last
  @result = @room.spin_for_member("nonexistent_member")
end

Then('spinning should fail with error {string}') do |message|
  expect(@result).not_to be_nil
  expect(@result[:success]).to eq(false)
  expect(@result[:error]).to eq(message)
end

Given('all restaurants are deleted') do
  Restaurant.delete_all
end

When('the host spins') do
  @room ||= Room.last
  owner_id = owner_member_id(@room)

  @room.update!(
    state: :spinning,
    turn_order: [owner_id],
    current_turn_index: 0
  )

  @result = @room.spin_for_member(owner_id)
end

Then('the room should remain in voting state') do
  @room.reload
  expect(@room.state).to eq("voting")
end

Then('starting a new round should fail') do
  expect(@result).to be_nil.or be false
end

Given('a restaurant exists with no categories or dietary restrictions') do
  @restaurant = Restaurant.create!(
    name: "Bare Restaurant",
    rating: 4.0,
    price: "$$",
    address: "123 Nowhere St",
    categories: nil,
    dietary_restrictions: nil
  )
end

Then('the restaurant should not have cuisine {string}') do |cuisine|
  expect(@restaurant.has_cuisine?(cuisine)).to be false
end

Then('the dietary restrictions list should be empty') do
  expect(@restaurant.dietary_restrictions_list).to eq([])
end

Given('a user login is validated without email or password') do
  user = User.new
  user.valid?(:login)
  @login_errors = user.errors
end

Then('login validation should fail') do
  expect(@login_errors[:email]).to be_present
  expect(@login_errors[:password]).to be_present
end

When('the host confirms their vote') do
  # Ensure the host has voted first
  owner_id = owner_member_id(@room)

  @room.vote(owner_id, 0)
  @confirm_result = @room.confirm_vote(owner_id)
end

When('the host tries to spin') do
  @room ||= Room.last
  owner_id = owner_member_id(@room)
  @result = @room.spin_for_member(owner_id)
end

Given('no restaurants match any filters') do
  Restaurant.delete_all
  Restaurant.create!(
    name: "Fallback Place",
    rating: 4.0,
    price: "$$",
    address: "123 Anywhere",
    categories: [],
    dietary_restrictions: ""
  )
end

Given('the room is in spinning state') do
  @room ||= Room.last
  owner_id = owner_member_id(@room)

  @room.update!(
    state: :spinning,
    turn_order: [owner_id],
    current_turn_index: 0
  )
end

Then('a restaurant should still be selected') do
  expect(@result).not_to be_nil
  expect(@result[:success]).to eq(true)
  expect(@result[:spin]).to be_present
  expect(@result[:spin]["restaurant"]).to be_present
end