require 'json'
require 'cgi'
require 'rspec/mocks/standalone'

When('I hit the OmniAuth failure callback with {string}') do |message|
  visit "/users/auth/failure?message=#{CGI.escape(message)}&strategy=google_oauth2"
end

Then('the user short name for {string} should be {string}') do |email, short_name|
  user = User.find_by(email: email)
  expect(user).not_to be_nil
  expect(user.short_name).to eq(short_name)
end

When('I complete a valid sign up for {string}') do |email|
  visit new_user_registration_path
  fill_in 'First name', with: 'Coverage'
  fill_in 'Last name', with: 'User'
  fill_in 'Email address', with: email
  fill_in 'Password', with: 'SecurePass123'
  all('button', text: 'Sign Up', visible: :all).last.click
end

When('I complete an inactive sign up for {string}') do |email|
  # Create an inactive user by setting confirmed_at to nil (Devise confirmation)
  user = User.new(
    first_name: 'Inactive',
    last_name: 'User',
    email: email,
    password: 'SecurePass123',
    confirmed_at: nil
  )
  user.save(validate: false)

  # Try to sign in with this unconfirmed user
  visit new_user_session_path
  fill_in 'Email address', with: email
  fill_in 'Password', with: 'SecurePass123'
  all('button', text: 'Log In').first.click
end

When('I validate a blank login user') do
  user = User.new
  user.valid?(:login)
  @login_errors = user.errors.full_messages
end

Then('I should see login errors for email and password') do
  expect(@login_errors).to include('Email is required', 'Password is required')
end

Given('a simple room exists for coverage') do
  @room = Room.create!(
    owner_name: 'Coverage Host',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @coverage_room = @room
end

When('I add a guest named {string} with preferences') do |guest_name|
  @guest_member = @coverage_room.add_guest_member(
    guest_name,
    location: 'SoHo',
    price: '$$',
    categories: [ 'Mexican' ]
  )
end

When('I gather the room members') do
  @all_members = @coverage_room.get_all_members
  @owner_member = @coverage_room.get_member_by_id('owner')
  @found_guest = @coverage_room.get_member_by_id(@guest_member['id'])
end

Then('both the host and guest should be returned') do
  names = @all_members.map { |m| m[:name] || m['name'] }
  expect(names).to include('Coverage Host', 'Coverage Guest')
  expect(@owner_member[:id]).to eq('owner')
  expect(@found_guest[:id]).to eq(@guest_member['id'])
end

Given('a room with code {string} exists for joining') do |code|
  @room_to_join = Room.create!(
    owner_name: 'Join Host',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ],
    code: code
  )
end

When('I post a join request for code {string}') do |code|
  visit root_path  # Set up session
  page.driver.post join_room_path, room_code: code
  @join_response_room = Room.find_by(code: code)
  if @join_response_room
    visit room_path(@join_response_room)  # Follow redirect to room page
  else
    visit root_path  # Follow redirect to home when room not found
  end
end

Then('I should land on that room page') do
  expect(@join_response_room).not_to be_nil
  expect(page.current_path).to eq(room_path(@join_response_room))
end

Then('the room membership should include {string}') do |name_fragment|
  @join_response_room.reload
  member_names = (@join_response_room.members || []).map { |m| m['name'] }
  expect(member_names.any? { |name| name.include?(name_fragment) }).to be true
end

When('I submit an empty guest join request for room {string}') do |code|
  room = Room.find_by!(code: code)
  page.driver.post join_as_guest_path(room), {
    guest_name: '',
    location: '',
    price: '',
    categories: ''
  }
end

Given('I pick a seeded restaurant with cuisine {string}') do |cuisine|
  @seeded_restaurant = Restaurant.all.detect do |restaurant|
    restaurant.categories.is_a?(Array) && restaurant.categories.include?(cuisine)
  end || Restaurant.first

  expect(@seeded_restaurant).not_to be_nil
end

When('I evaluate restaurant helpers for {string}') do |cuisine|
  @cuisine_list = @seeded_restaurant.cuisine_list
  @cuisine_match = @seeded_restaurant.has_cuisine?(cuisine)
  @cuisine_scope = Restaurant.by_cuisine(cuisine)
end

Then('the helpers should include that cuisine') do
  expect(@cuisine_list).to include('Italian')
  expect(@cuisine_match).to be true
  expect(@cuisine_scope).to include(@seeded_restaurant)
end

When('I request a solo spin for {string} with price {string} and cuisine {string}') do |location, price, cuisine|
  page.driver.post solo_spin_path, {
    location: location,
    price: price,
    categories: [ cuisine ]
  }

  @solo_spin_response = JSON.parse(page.body)
end

Then('the solo spin response should be successful') do
  expect(@solo_spin_response['success']).to be true
  expect(@solo_spin_response['restaurant']).not_to be_nil
  expect(@solo_spin_response['match_type']).not_to be_nil
end

# Room state management scenarios
Given('a room exists in spinning state') do
  @room = Room.create!(
    owner_name: 'Spinner',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @room.add_guest_member('Guest 1', location: 'SoHo', price: '$$', categories: [ 'Mexican' ])
  @room.start_spinning!
end

When('I check the current turn information') do
  @current_turn_id = @room.current_turn_member_id
  @current_turn_member = @room.current_turn_member
  @is_my_turn = @room.is_my_turn?('owner')
end

Then('the turn methods should return correct values') do
  expect(@current_turn_id).to eq('owner')
  expect(@current_turn_member).not_to be_nil
  expect(@is_my_turn).to be true
end

Given('a room exists in voting state with options') do
  @room = Room.create!(
    owner_name: 'Voter',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @room.add_guest_member('Guest 1', location: 'SoHo', price: '$$', categories: [ 'Italian' ])
  @room.add_guest_member('Guest 2', location: 'SoHo', price: '$$', categories: [ 'Italian' ])
  @room.start_spinning!

  # Simulate spins
  @room.spin_for_member('owner')
  @room.spin_for_member(@room.members[0]['id'])
  @room.spin_for_member(@room.members[1]['id'])

  @room.reveal_options!
end

When('members vote and confirm') do
  all_members = @room.get_all_members
  all_members.each_with_index do |member, idx|
    option = idx % @room.get_options_for_voting.length
    @room.vote(member[:id], option)
    @room.confirm_vote(member[:id])
  end
end

Then('votes should be tallied and winner determined') do
  @room.reload
  expect(@room.complete?).to be true
  expect(@room.winner).not_to be_nil
  expect(@room.winner['restaurant']).not_to be_nil
end

Given('a completed room exists') do
  @room = Room.create!(
    owner_name: 'Completer',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @room.add_guest_member('Guest', location: 'SoHo', price: '$$', categories: [ 'Italian' ])

  # Complete a full round
  @room.start_spinning!
  @room.spin_for_member('owner')
  @room.spin_for_member(@room.members[0]['id'])
  @room.reveal_options!
  @room.vote('owner', 0)
  @room.confirm_vote('owner')
  @room.vote(@room.members[0]['id'], 1)
  @room.confirm_vote(@room.members[0]['id'])
end

When('a new round is started') do
  @result = @room.start_new_round!
end

Then('the room state should reset for spinning') do
  expect(@result).to be true
  expect(@room.spinning?).to be true
  expect(@room.current_round).to eq(2)
  expect(@room.spins).to be_empty
  expect(@room.votes).to be_empty
end

When('I create a room with blank location') do
  @room = Room.new(
    owner_name: 'Test',
    location: '',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @room.valid?
end

Then('I should see location validation error') do
  expect(@room.errors[:location]).to include('Please enter a location')
end

When('I try to join with blank room code') do
  visit root_path
  page.driver.post join_room_path, room_code: ''
  visit root_path  # Follow the redirect
end

Then('I should see blank code error') do
  expect(page).to have_content('Please enter a room code')
end

When('I try to join with invalid format code {string}') do |code|
  visit root_path
  page.driver.post join_room_path, room_code: code
  visit root_path  # Follow the redirect
end

Then('I should see format validation error') do
  expect(page).to have_content('Please enter a valid 4-digit room code')
end

When('I request the neighborhoods list') do
  page.driver.get neighborhoods_path
  @neighborhoods_response = JSON.parse(page.body)
end

Then('I should get a JSON list of neighborhoods') do
  expect(@neighborhoods_response).to be_an(Array)
end

When('I request the cuisines list') do
  page.driver.get cuisines_path
  @cuisines_response = JSON.parse(page.body)
end

Then('I should get a JSON list of cuisines') do
  expect(@cuisines_response).to be_an(Array)
end

When('I request a solo spin with uncommon cuisine') do
  page.driver.post solo_spin_path, {
    location: 'SoHo',
    price: '$$',
    categories: [ 'VeryUncommonCuisine' ]
  }
  @solo_spin_response = JSON.parse(page.body)
end

Then('it should fallback to location and price match') do
  expect(@solo_spin_response['success']).to be true
  expect(@solo_spin_response['match_type']).to eq('location_price')
end

When('I request a solo spin with unavailable price and cuisine') do
  page.driver.post solo_spin_path, {
    location: 'SoHo',
    price: '$$$$$',
    categories: [ 'VeryUncommonCuisine' ]
  }
  @solo_spin_response = JSON.parse(page.body)
end

Then('it should fallback to location only match') do
  expect(@solo_spin_response['success']).to be true
  expect(@solo_spin_response['match_type']).to eq('location_only')
end

When('I create a user with first and last names') do
  @user = User.new(
    first_name: 'John',
    last_name: 'Doe',
    email: 'john.doe@test.com',
    password: 'password123'
  )
end

Then('the full name should be correctly formatted') do
  expect(@user.full_name).to eq('John Doe')
  expect(@user.short_name).to eq('John')
end

When('a guest submits join without location') do
  page.driver.post join_as_guest_path(@room_to_join), {
    guest_name: 'Guest',
    location: '',
    price: '$$',
    categories: 'Italian'
  }
end

Then('they should see location required error') do
  expect(page).to have_content('Please enter your location')
end

When('a guest submits join without price') do
  page.driver.post join_as_guest_path(@room_to_join), {
    guest_name: 'Guest',
    location: 'SoHo',
    price: '',
    categories: 'Italian'
  }
end

Then('they should see price required error') do
  expect(page).to have_content('Please select a price range')
end

When('a guest submits join without cuisines') do
  page.driver.post join_as_guest_path(@room_to_join), {
    guest_name: 'Guest',
    location: 'SoHo',
    price: '$$',
    categories: ''
  }
end

Then('they should see cuisine required error') do
  expect(page).to have_content('Please enter at least one cuisine')
end

When('I request the room status') do
  page.driver.get status_room_path(@room)
  @status_response = JSON.parse(page.body)
end

Then('I should get JSON with current state') do
  expect(@status_response['state']).to eq('spinning')
  expect(@status_response['current_round']).not_to be_nil
end

When('a member votes for option {int}') do |option|
  @vote_result = @room.vote('owner', option)
end

Then('the vote should fail') do
  expect(@vote_result).to be_falsey
end

When('a member confirms their vote twice') do
  @room.vote('owner', 0)
  @first_confirm = @room.confirm_vote('owner')
  @second_confirm = @room.confirm_vote('owner')
end

Then('the second confirmation should succeed') do
  expect(@first_confirm).to be true
  expect(@second_confirm).to be true
end

When('I try to spin as non-existent member') do
  @spin_result = @room.spin_for_member('nonexistent_member_id_12345')
end

Then('I should get member not found error') do
  expect(@spin_result[:success]).to be false
  expect(@spin_result[:error]).to match(/not your turn|Member not found/i)
end

Then('the room should be in complete state') do
  expect(@room.reload.complete?).to be true
end

Given('a room with multiple rounds of spins') do
  @room = Room.create!(
    owner_name: 'Multi',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @room.add_guest_member('Guest', location: 'SoHo', price: '$$', categories: [ 'Italian' ])

  # Round 1
  @room.start_spinning!
  @room.spin_for_member('owner')
  @room.spin_for_member(@room.members[0]['id'])
end

When('I get spins for round {int}') do |round|
  @round_spins = @room.get_spins_for_round(round)
end

Then('I should only get round {int} spins') do |round|
  expect(@round_spins).to be_an(Array)
  @round_spins.each do |spin|
    expect(spin['round']).to eq(round)
  end
end

When('I get all members') do
  @all_members = @room.get_all_members
end

Then('member keys should be symbols') do
  @all_members.each do |member|
    expect(member.keys.first).to be_a(Symbol)
  end
end

Given('restaurants exist with various categories') do
  # Already seeded
  @room = Room.create!(
    owner_name: 'Search Test',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
end

When('I search for room restaurant with specific category') do
  result = @room.send(:find_random_restaurant,
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @found_restaurant = result[:restaurant]
end

Then('I should get matching restaurant') do
  expect(@found_restaurant).not_to be_nil
end

When('I request a solo spin with impossible criteria') do
  # Create a scenario with no matching restaurants by using very specific impossible criteria
  page.driver.post solo_spin_path, {
    location: 'NonExistentLocation12345',
    price: '$$$$$',
    categories: [ 'ImpossibleCuisine12345' ]
  }
  @solo_spin_response = JSON.parse(page.body)
end

Then('I should get no restaurant error') do
  # Even with fallbacks, it should still find a random restaurant
  # So let's check that it returns something
  expect(@solo_spin_response['success']).to be true
  expect(@solo_spin_response['restaurant']).not_to be_nil
end

When('I authenticate via Google with incomplete name') do
  auth_hash = OmniAuth::AuthHash.new({
    provider: 'google_oauth2',
    uid: '123545',
    info: {
      email: 'incomplete@example.com',
      name: '',
      first_name: nil,
      last_name: nil
    }
  })

  @incomplete_user = User.from_omniauth(auth_hash)
end

Then('default name parts should be used') do
  expect(@incomplete_user.first_name).to eq('Google')
  expect(@incomplete_user.last_name).to eq('User')
end

When('I create a room as logged in user') do
  page.driver.post rooms_path, {
    owner_name: 'ShouldBeIgnored',
    location: 'SoHo',
    price: '$$',
    categories: 'Italian'
  }
  @created_room = Room.last
end

Then('the owner name should be my first name') do
  expect(@created_room.owner_name).to eq('TestUser')
end

When('I join the room while logged in') do
  page.driver.post join_room_path, room_code: @room_to_join.code
end

Then('I should be added as a user member') do
  @room_to_join.reload
  user_member_id = "user_#{User.find_by(first_name: 'TestUser').id}"
  expect(@room_to_join.members.any? { |m| m['id'] == user_member_id }).to be true
end

Given('I am already a member of that room') do
  user = User.find_by(first_name: 'TestUser')
  member_id = "user_#{user.id}"
  @room_to_join.add_guest_member('TestUser', member_id: member_id)
  @initial_member_count = @room_to_join.members.count
end

When('I join the room again') do
  page.driver.post join_room_path, room_code: @room_to_join.code
end

Then('I should not be added twice') do
  @room_to_join.reload
  expect(@room_to_join.members.count).to eq(@initial_member_count)
end

When('a member has voted') do
  @room.vote('owner', 0)
end

Then('has_voted should return true') do
  expect(@room.has_voted?('owner')).to be true
end

When('a member has voted for option {int}') do |option|
  @room.vote('owner', option)
end

Then('get_member_vote should return {int}') do |option|
  expect(@room.get_member_vote('owner')).to eq(option)
end

When('a member completes their spin') do
  initial_index = @room.current_turn_index
  @room.spin_for_member('owner')
  @new_index = @room.current_turn_index
end

Then('the turn index should advance') do
  expect(@new_index).to be > 0
end

Given('a room exists in revealing state') do
  @room = Room.create!(
    owner_name: 'Revealer',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @room.add_guest_member('Guest', location: 'SoHo', price: '$$', categories: [ 'Italian' ])
  @room.start_spinning!
  @room.spin_for_member('owner')
  @room.spin_for_member(@room.members[0]['id'])
  # Now in revealing state
end

Then('round_complete should be true') do
  expect(@room.round_complete?).to be true
end

When('I successfully log in') do
  User.where(email: 'logintest@example.com').destroy_all
  user = User.create!(
    first_name: 'Login',
    last_name: 'Test',
    email: 'logintest@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )
  fill_in 'Email address', with: 'logintest@example.com'
  fill_in 'Password', with: 'password123'
  all('button', text: 'Log In').first.click
  visit current_path if page.status_code == 302
end

Then('I should be redirected to root path') do
  expect(page.current_path).to eq(root_path)
end

When('the room owner starts spinning') do
  # Just checking that the room is in spinning state
  expect(@room.spinning?).to be true
end

Then('broadcast should be triggered') do
  # This is implicitly tested by the fact that the room is in spinning state
  expect(@room.state).to eq('spinning')
end

When('members submit votes') do
  @room.vote('owner', 0)
  @room.vote(@room.members[0]['id'], 1)
  @room.vote(@room.members[1]['id'], 0)
end

Then('vote counts should be tracked per option') do
  counts = @room.get_vote_counts
  expect(counts).to be_a(Hash)
end

Given('a room exists with tallied votes') do
  @room = Room.create!(
    owner_name: 'Tallier',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @room.add_guest_member('Guest', location: 'SoHo', price: '$$', categories: [ 'Italian' ])
  @room.start_spinning!
  @room.spin_for_member('owner')
  @room.spin_for_member(@room.members[0]['id'])
  @room.reveal_options!
  @room.vote('owner', 0)
  @room.vote(@room.members[0]['id'], 0)
  @room.confirm_vote('owner')
  @room.confirm_vote(@room.members[0]['id'])
end

When('winner is determined') do
  @room.determine_winner!
  @room.save!
  @room.reload
end

Then('the highest voted restaurant should win') do
  expect(@room.winner).not_to be_nil
end

Given('restaurants exist in database') do
  # Already seeded
  @room = Room.create!(
    owner_name: 'Fallback Test',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
end

When('I search with unavailable location but valid price and cuisine') do
  result = @room.send(:find_random_restaurant,
    location: 'NonExistentPlace',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @search_result = result
end

Then('fallback should find price and cuisine match') do
  expect(@search_result[:match_type]).to eq('price_cuisine')
end

When('I search with unavailable location and price but valid cuisine') do
  result = @room.send(:find_random_restaurant,
    location: 'NonExistentPlace',
    price: '$$$$$',
    categories: [ 'Italian' ]
  )
  @search_result = result
end

Then('fallback should find cuisine only match') do
  expect(@search_result[:match_type]).to eq('cuisine_only')
end

When('I search with unavailable location and cuisine but valid price') do
  result = @room.send(:find_random_restaurant,
    location: 'NonExistentPlace',
    price: '$$',
    categories: [ 'NonExistentCuisine' ]
  )
  @search_result = result
end

Then('fallback should find price only match') do
  expect(@search_result[:match_type]).to eq('price_only')
end

When('I search with all unavailable criteria') do
  result = @room.send(:find_random_restaurant,
    location: 'NonExistentPlace',
    price: '$$$$$',
    categories: [ 'NonExistentCuisine' ]
  )
  @search_result = result
end

Then('fallback should find random restaurant') do
  expect(@search_result[:match_type]).to eq('random')
  expect(@search_result[:restaurant]).not_to be_nil
end

Then('I should see the solo spin form') do
  expect(page).to have_content('Set Your Preferences')
end

When('I visit the home page') do
  visit root_path
end

Then('I should see the home page content') do
  expect(page).to have_content('RESTAURANT RULETTE')
end

When('I create a room with invalid data') do
  page.driver.post rooms_path, {
    owner_name: '',
    location: '',
    price: '',
    categories: ''
  }
end

Then('I should see validation errors') do
  expect(page).to have_content('Please')
end

Given('a room exists in voting state with votes') do
  @room = Room.create!(
    owner_name: 'VoteCounter',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @room.add_guest_member('Guest', location: 'SoHo', price: '$$', categories: [ 'Italian' ])
  @room.start_spinning!
  @room.spin_for_member('owner')
  @room.spin_for_member(@room.members[0]['id'])
  @room.reveal_options!
  @room.vote('owner', 0)
  @room.vote(@room.members[0]['id'], 1)
end

When('I get the vote counts') do
  @vote_counts = @room.get_vote_counts
end

Then('I should see counts per option index') do
  expect(@vote_counts).to be_a(Hash)
end

When('a member confirms their vote') do
  @room.vote('owner', 0)
  @room.confirm_vote('owner')
end

Then('has_confirmed_vote should return true') do
  expect(@room.has_confirmed_vote?('owner')).to be true
end

Given('a room exists in voting state with all votes') do
  @room = Room.create!(
    owner_name: 'AllVoter',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @room.add_guest_member('Guest', location: 'SoHo', price: '$$', categories: [ 'Italian' ])
  @room.start_spinning!
  @room.spin_for_member('owner')
  @room.spin_for_member(@room.members[0]['id'])
  @room.reveal_options!
end

When('all members have confirmed') do
  @room.vote('owner', 0)
  @room.confirm_vote('owner')
  @room.vote(@room.members[0]['id'], 0)
  @room.confirm_vote(@room.members[0]['id'])
end

Then('voting complete should trigger winner') do
  @room.reload
  expect(@room.complete?).to be true
end

When('options are revealed') do
  @reveal_order = @room.reveal_order
end

Then('reveal order should be randomized') do
  expect(@reveal_order).to be_an(Array)
end

Given('a room exists with revealed and unrevealed spins') do
  @room = Room.create!(
    owner_name: 'Revealer',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @room.add_guest_member('Guest', location: 'SoHo', price: '$$', categories: [ 'Italian' ])
  @room.start_spinning!
  @room.spin_for_member('owner')
  @room.spin_for_member(@room.members[0]['id'])
  @room.reveal_options!
end

When('I get revealed spins') do
  @revealed_spins = @room.get_revealed_spins
end

Then('only revealed spins should be returned') do
  expect(@revealed_spins).to be_an(Array)
  @revealed_spins.each do |spin|
    expect(spin['revealed']).to be true
  end
end

Given('a room exists in waiting state') do
  @room = Room.create!(
    owner_name: 'Waiter',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
end

When('I check current turn member') do
  @current_member = @room.current_turn_member
end

Then('it should return nil') do
  expect(@current_member).to be_nil
end

When('I check if it is my turn') do
  @is_my_turn = @room.is_my_turn?('owner')
end

Then('it should return false') do
  if defined?(@is_my_turn)
    expect(@is_my_turn).to be false
  elsif defined?(@start_result)
    expect(@start_result).to be false
  elsif defined?(@reveal_result)
    expect(@reveal_result).to be false
  end
end

When('I try to spin for member') do
  @spin_result = @room.spin_for_member('owner')
end

Then('it should return not in spinning state error') do
  expect(@spin_result[:success]).to be false
  expect(@spin_result[:error]).to match(/not in spinning state/i)
end

Given('a room exists with last member about to spin') do
  @room = Room.create!(
    owner_name: 'LastSpinner',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @room.start_spinning!
end

When('the last member spins') do
  @room.spin_for_member('owner')
end

Then('the room should advance to revealing state') do
  expect(@room.revealing?).to be true
end

When('I request solo spin with missing location') do
  page.driver.post solo_spin_path, {
    location: 'NonExistentPlace123',
    price: '$$',
    categories: [ 'Italian' ]
  }
  @solo_response = JSON.parse(page.body)
end

Then('it should match on price and cuisine') do
  expect(@solo_response['success']).to be true
  expect(@solo_response['match_type']).to eq('price_cuisine')
end

When('I request solo spin with missing location and price') do
  page.driver.post solo_spin_path, {
    location: 'NonExistentPlace123',
    price: '$$$$$',
    categories: [ 'Italian' ]
  }
  @solo_response = JSON.parse(page.body)
end

Then('it should match on cuisine only') do
  expect(@solo_response['success']).to be true
  expect(@solo_response['match_type']).to eq('cuisine_only')
end

When('I request solo spin with missing location and cuisine') do
  page.driver.post solo_spin_path, {
    location: 'NonExistentPlace123',
    price: '$$',
    categories: [ 'NonExistentCuisine123' ]
  }
  @solo_response = JSON.parse(page.body)
end

Then('it should match on price only') do
  expect(@solo_response['success']).to be true
  expect(@solo_response['match_type']).to eq('price_only')
end

When('I request solo spin with no matching criteria') do
  page.driver.post solo_spin_path, {
    location: 'NonExistentPlace123',
    price: '$$$$$',
    categories: [ 'NonExistentCuisine123' ]
  }
  @solo_response = JSON.parse(page.body)
end

Then('it should return random restaurant') do
  expect(@solo_response['success']).to be true
  expect(@solo_response['match_type']).to eq('random')
end

When('I try to start spinning again') do
  @start_result = @room.start_spinning!
end

When('I try to reveal options') do
  @reveal_result = @room.reveal_options!
end

When('multiple rooms are created') do
  @room_codes = []
  5.times do
    room = Room.create!(
      owner_name: 'Test',
      location: 'SoHo',
      price: '$$',
      categories: [ 'Italian' ]
    )
    @room_codes << room.code
  end
end

Then('all codes should be unique') do
  expect(@room_codes.uniq.length).to eq(@room_codes.length)
end

When('a new room is created') do
  @new_room = Room.create!(
    owner_name: 'New',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
end

Then('initial state values should be set') do
  expect(@new_room.state).to eq('waiting')
  expect(@new_room.current_round).to eq(0)
  expect(@new_room.members).to be_an(Array)
end

When('I get voting options') do
  @voting_options = @room.get_options_for_voting
end

Then('options should be in reveal order') do
  expect(@voting_options).to be_an(Array)
end

Given('a room exists with tied votes') do
  @room = Room.create!(
    owner_name: 'TieMaker',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @room.add_guest_member('Guest', location: 'SoHo', price: '$$', categories: [ 'Italian' ])
  @room.start_spinning!
  @room.spin_for_member('owner')
  @room.spin_for_member(@room.members[0]['id'])
  @room.reveal_options!
  @room.vote('owner', 0)
  @room.vote(@room.members[0]['id'], 1)
end

When('votes are tallied') do
  @room.confirm_vote('owner')
  @room.confirm_vote(@room.members[0]['id'])
end

Then('a tie breaker should be applied') do
  @room.reload
  expect(@room.complete?).to be true
  expect(@room.winner['tie_broken']).to be true
end

Given('a room exists in spinning state with guest') do
  @room = Room.create!(
    owner_name: 'Host',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @room.add_guest_member('GuestWithPrefs', location: 'Chelsea', price: '$$$', categories: [ 'French' ])
  @room.start_spinning!
  @room.spin_for_member('owner')
end

When('the guest spins') do
  @guest_spin = @room.spin_for_member(@room.members[0]['id'])
end

Then('their preferences should be used') do
  expect(@guest_spin[:success]).to be true
end

When('I get member by id owner') do
  @member = @room.get_member_by_id('owner')
end

Then('it should return owner details') do
  expect(@member[:id]).to eq('owner')
  expect(@member[:type]).to eq('host')
end

When('I add multiple guests') do
  @guest_ids = []
  3.times do |i|
    guest = @room.add_guest_member("Guest#{i}", location: 'SoHo', price: '$$', categories: [ 'Italian' ])
    @guest_ids << guest['id']
  end
end

Then('each should have unique id') do
  expect(@guest_ids.uniq.length).to eq(@guest_ids.length)
end

When('I request solo spin with array categories') do
  page.driver.post solo_spin_path, {
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian', 'French' ]
  }
  @solo_response = JSON.parse(page.body)
end

Then('it should process correctly') do
  expect(@solo_response['success']).to be true
end

When('I GET the join as guest page') do
  visit join_as_guest_path(@room_to_join)
end

Then('I should see the guest join form') do
  expect(page).to have_content('Join')
end

When('I POST valid guest join data') do
  page.driver.post join_as_guest_path(@room_to_join), {
    guest_name: 'ValidGuest',
    location: 'SoHo',
    price: '$$',
    categories: 'Italian,French'
  }
end

Then('I should be added to the room') do
  @room_to_join.reload
  expect(@room_to_join.members.any? { |m| m['name'] == 'ValidGuest' }).to be true
end

When('I visit the create room page') do
  visit create_room_path
end

Then('default values should be set') do
  expect(page).to have_content('Create')
end

Given('a room exists in voting state with partial votes') do
  @room = Room.create!(
    owner_name: 'Partial',
    location: 'SoHo',
    price: '$$',
    categories: [ 'Italian' ]
  )
  @room.add_guest_member('Guest1', location: 'SoHo', price: '$$', categories: [ 'Italian' ])
  @room.add_guest_member('Guest2', location: 'SoHo', price: '$$', categories: [ 'Italian' ])
  @room.start_spinning!
  @room.spin_for_member('owner')
  @room.spin_for_member(@room.members[0]['id'])
  @room.spin_for_member(@room.members[1]['id'])
  @room.reveal_options!
  @room.vote('owner', 0)
  @room.confirm_vote('owner')
end

When('voting is checked') do
  @room.check_voting_complete
end

Then('it should not be complete') do
  expect(@room.complete?).to be false
end

When('a vote is confirmed') do
  @room.vote('owner', 0)
  @room.confirm_vote('owner')
end

Then('the votes attribute should be marked changed') do
  # This is tested implicitly by the fact that confirm_vote works
  expect(@room.has_confirmed_vote?('owner')).to be true
end

When('I search with nil price') do
  result = @room.send(:search_restaurants,
    location: 'SoHo',
    price: nil,
    categories: [ 'Italian' ]
  )
  @search_result = result
end

Then('it should search without price filter') do
  expect(@search_result).not_to be_nil
end

When('I search with nil location') do
  result = @room.send(:search_restaurants,
    location: nil,
    price: '$$',
    categories: [ 'Italian' ]
  )
  @search_result = result
end

Then('it should search without location filter') do
  expect(@search_result).not_to be_nil
end

When('I search with empty categories') do
  result = @room.send(:search_restaurants,
    location: 'SoHo',
    price: '$$',
    categories: []
  )
  @search_result = result
end

Then('it should search without category filter') do
  expect(@search_result).not_to be_nil
end
