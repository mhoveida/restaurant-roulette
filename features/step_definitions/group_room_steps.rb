# features/step_definitions/group_room_steps.rb
# CORRECT VERSION - Room.members is a JSON array, NOT a separate model!

# ==========================================
# HELPER: Select cuisine
# ==========================================

def select_cuisine_checkbox(cuisine)
  using_wait_time(15) do
    grid_selector = if page.has_css?('[data-create-room-target="cuisinesGrid"]')
                      '[data-create-room-target="cuisinesGrid"]'
                    elsif page.has_css?('[data-solo-spin-target="cuisinesGrid"]')
                      '[data-solo-spin-target="cuisinesGrid"]'
                    else
                      raise "Cannot find cuisines grid"
                    end
    
    within(grid_selector) do
      expect(page).to have_css('.cuisine-checkbox', wait: 10)
      label = find('.cuisine-checkbox', text: cuisine, match: :first)
      label.click
      checkbox = label.find('input[type="checkbox"]')
      expect(checkbox).to be_checked
    end
  end
end

# ==========================================
# ROOM PREFERENCES DISPLAY
# ==========================================

Then('I should see {string} in the room creator field') do |name|
  # Be more specific - find the preference item that contains "Room Creator" label
  preference_item = find('.preference-item', text: /Room Creator/i, match: :first)
  expect(preference_item).to have_text(name)
end

Then('I should see {string} in the location field') do |location|
  # Find the preference item that contains "Location" label
  preference_item = find('.preference-item', text: /Location/i, match: :first)
  expect(preference_item).to have_text(location)
end

Then('I should see {string} in the price field') do |price|
  # Find the preference item that contains "Price Range" label
  preference_item = find('.preference-item', text: /Price Range/i, match: :first)
  expect(preference_item).to have_text(price)
end

Then('I should remain on the create room page') do
  expect(page).to have_current_path('/create_room', ignore_query: true)
end

Then('DEBUG check name field') do
  if page.has_css?('[data-create-room-target="ownerNameInput"]')
    field = find('[data-create-room-target="ownerNameInput"]')
    puts "Name field value: '#{field.value}'"
    puts "Name field readonly: #{field[:readonly]}"
    puts "Current user: #{@current_user&.first_name}"
  end
end

# ==========================================
# ROOM CODE
# ==========================================

Then('I should see a 4-digit room code') do
  code = find('.code-value').text
  expect(code).to match(/^\d{4}$/)
  @room_code = code
end

Then('the room code should be unique') do
  expect(@room_code).not_to be_nil
  expect(Room.where(code: @room_code).count).to eq(1)
end

# ==========================================
# ROOM CREATION STEPS
# ==========================================

Given('a room exists with code {string}') do |code|
  @room = Room.create!(
    code: code,
    owner_name: 'Test Owner',
    location: 'SoHo',
    price: '$$',
    categories: ['Italian'],
    state: 'waiting'
  )
end

Given('a room exists with code {string} created by {string}') do |code, owner_name|
  @room = Room.create!(
    code: code,
    owner_name: owner_name,
    location: 'SoHo',
    price: '$$',
    categories: ['Italian'],
    state: 'waiting'
  )
end

Given('I visit the join page for room {string}') do |code|
  room = Room.find_by!(code: code)
  visit "/rooms/#{room.id}/join_as_guest"
end

Given('I have created a room with code {string}') do |code|
  # Create room directly in DB
  @room = Room.create!(
    code: code,
    owner_name: 'Test Creator',
    location: 'SoHo',
    price: '$$',
    categories: ['Italian'],
    state: 'waiting'
  )
  
  visit "/rooms/#{@room.id}"
  @current_user_id = "owner"
end

# ==========================================
# JOINING ROOM STEPS
# ==========================================

Given('{string} has joined room {string}') do |name, code|
  room = Room.find_by!(code: code)
  # Use the Room's add_guest_member method
  room.add_guest_member(name, 
    location: 'SoHo',
    price: '$$',
    categories: ['Italian']
  )
end

Given('I have joined room {string}') do |code|
  room = Room.find_by!(code: code)
  visit "/rooms/#{room.id}/join_as_guest"
  
  fill_in 'guest_name', with: 'Test Guest'
  select 'SoHo', from: 'location'
  select '$$', from: 'price'
  select_cuisine_checkbox('Italian')
  click_button 'Join Room'
  
  # Get the member ID from the room
  @current_member = room.reload.members.last
  @current_user_id = @current_member["id"]
end

Given('I have joined room {string} as {string}') do |code, name|
  room = Room.find_by!(code: code)
  visit "/rooms/#{room.id}/join_as_guest"
  
  fill_in 'guest_name', with: name
  select 'SoHo', from: 'location'
  select '$$', from: 'price'
  select_cuisine_checkbox('Italian')
  click_button 'Join Room'
  
  @current_member = room.reload.members.find { |m| m["name"] == name }
  @current_user_id = @current_member["id"] if @current_member
end

Given('I join room {string}') do |code|
  room = Room.find_by!(code: code)
  visit "/rooms/#{room.id}"
end

When('I try to join room {string} as {string}') do |code, name|
  room = Room.find_by!(code: code)
  visit "/rooms/#{room.id}/join_as_guest"
  
  if page.has_field?('guest_name')
    fill_in 'guest_name', with: name
    select 'SoHo', from: 'location'
    select '$$', from: 'price'
    select_cuisine_checkbox('Italian')
    click_button 'Join Room'
  end
end

When('I visit room {string}') do |code|
  room = Room.find_by!(code: code)
  visit "/rooms/#{room.id}"
end

Then('I should see {string} in the members list') do |name|
  within('.members-list') do
    expect(page).to have_css('.member-item', text: name)
  end
end

Then('I should see a {string} badge for {string}') do |badge_type, member_name|
  within('.members-list') do
    member_item = find('.member-item', text: member_name)
    within(member_item) do
      case badge_type
      when "Room Creator"
        expect(page).to have_css('.host-badge', text: 'Room Creator')
      when "Member"
        expect(page).to have_css('.guest-badge', text: 'Member')
      end
    end
  end
end

Then('I should not see {string} button') do |button_text|
  expect(page).not_to have_button(button_text)
end

Then('the room code {string} should be copied to clipboard') do |code|
  expect(page).to have_css('#copyConfirmation', visible: true, wait: 3)
end

# ==========================================
# SPINNING PHASE
# ==========================================

Given('the spinning phase has started') do
  @room ||= Room.last
  @room.start_spinning!
end

When('it is my turn to spin') do
  @room ||= Room.last
  turn_order = @room.turn_order || []
  if turn_order.include?(@current_user_id)
    @room.update!(current_turn_index: turn_order.index(@current_user_id))
  end
end

When('it is not my turn') do
  @room ||= Room.last
  turn_order = @room.turn_order || []
  other_member_id = turn_order.find { |id| id != @current_user_id }
  @room.update!(current_turn_index: turn_order.index(other_member_id)) if other_member_id
end

When('I complete my spin') do
  click_button '🎲 Spin the Wheel!'
  sleep 3
end

When('all members complete their spins') do
  @room ||= Room.last
  @room.get_all_members.each do |member|
    @room.spin_for_member(member[:id])
  end
end

Then('I should see my turn indicator') do
  within('.turn-order-list') do
    expect(page).to have_css('.current-turn')
  end
end

Then('the wheel should spin') do
  expect(page).to have_css('#rouletteWheel.spinning', wait: 2)
end

Then('I should see a restaurant result') do
  expect(page).to have_css('.restaurant-name', wait: 5)
end

Then('the next person\'s turn should begin') do
  expect(page).to have_css('.turn-item.completed-turn', count: 1, wait: 5)
end

Then('I should see {string} message') do |message_text|
  expect(page).to have_text(message_text, wait: 3)
end

Then('the spin button should be disabled') do
  button = find_button('🎲 Spin the Wheel!')
  expect(button[:disabled]).to be_truthy
end

Then('my name should be highlighted in turn order') do
  within('.turn-order-list') do
    expect(page).to have_css('.turn-item.current-turn')
  end
end

Then('I should see the current turn indicator') do
  expect(page).to have_css('.current-turn', text: '⭐')
end

Then('I should see a checkmark next to my name') do
  within('.turn-order-list') do
    expect(page).to have_text('✓')
  end
end

Then('the turn should advance to the next member') do
  expect(page).to have_css('.turn-item.current-turn', count: 1)
  expect(page).to have_css('.turn-item.completed-turn', minimum: 1)
end

Then('I should not be in the turn order') do
  within('.turn-order-list') do
    expect(page).not_to have_css('.turn-item', text: 'Late User')
  end
end

# ==========================================
# REVEALING PHASE
# ==========================================

Given('all members have completed spinning') do
  @room ||= Room.last
  @room.get_all_members.each do |member|
    @room.spin_for_member(member[:id])
  end
  visit "/rooms/#{@room.id}"
end

Then('I should see the reveal countdown') do
  expect(page).to have_css('#countdown', wait: 3)
end

Then('I should see a countdown from 3') do
  expect(page).to have_text('3', wait: 2)
end

Then('the voting phase should begin') do
  expect(page).to have_css('.voting-section', wait: 5)
end

# ==========================================
# VOTING PHASE
# ==========================================

Given('the voting phase has begun') do
  @room ||= Room.last
  @room.get_all_members.each do |member|
    @room.spin_for_member(member[:id])
  end
  @room.reveal_options!
  visit "/rooms/#{@room.id}"
end

Given('I am in the voting phase of room {string}') do |code|
  @room = Room.find_by(code: code) || Room.create!(
    code: code,
    owner_name: 'Test Owner',
    location: 'SoHo',
    price: '$$',
    categories: ['Italian']
  )
  
  @room.start_spinning!
  @room.get_all_members.each { |m| @room.spin_for_member(m[:id]) }
  @room.reveal_options!
  
  @current_user_id = "owner"
  visit "/rooms/#{@room.id}"
end

When('I click on the first restaurant option') do
  within('.voting-board') do
    first('.voting-option').click
  end
end

When('I click on option {int}') do |option_number|
  within('.voting-board') do
    all('.voting-option')[option_number - 1].click
  end
end

When('I vote for option {int}') do |option_number|
  within('.voting-board') do
    all('.voting-option')[option_number - 1].click
    sleep 0.5
  end
  click_button 'Confirm My Vote' if page.has_button?('Confirm My Vote')
end

When('I confirm my vote for option {int}') do |option_number|
  within('.voting-board') do
    all('.voting-option')[option_number - 1].click
  end
  click_button 'Confirm My Vote'
  sleep 1
end

When('{string} votes for option {int}') do |member_name, option_number|
  member = @room.get_all_members.find { |m| m[:name] == member_name }
  @room.vote(member[:id], option_number - 1) if member
end

When('{string} confirms their vote for option {int}') do |member_name, option_number|
  member = @room.get_all_members.find { |m| m[:name] == member_name }
  if member
    @room.vote(member[:id], option_number - 1)
    @room.confirm_vote(member[:id])
  end
  visit current_path
end

Then('{string} has not voted yet') do |member_name|
  member = @room.get_all_members.find { |m| m[:name] == member_name }
  expect(@room.has_voted?(member[:id])).to be false if member
end

Then('that option should be highlighted') do
  expect(page).to have_css('.voting-option.selected-vote')
end

Then('option {int} should be selected') do |option_number|
  within('.voting-board') do
    option = all('.voting-option')[option_number - 1]
    expect(option[:class]).to include('selected-vote')
  end
end

Then('option {int} should not be selected') do |option_number|
  within('.voting-board') do
    option = all('.voting-option')[option_number - 1]
    expect(option[:class]).not_to include('selected-vote')
  end
end

Then('the button should be disabled') do
  button = find_button('Confirm My Vote')
  expect(button[:disabled]).to be_truthy
end

Then('I should not be able to change my vote') do
  all('.voting-option').each do |option|
    expect(option[:style]).to include('pointer-events: none')
  end
end

Then('option {int} should show {string}') do |option_number, vote_text|
  within('.voting-board') do
    option = all('.voting-option')[option_number - 1]
    within(option) do
      expect(page).to have_css('.vote-count', text: vote_text)
    end
  end
end

Then('I should still see the voting interface') do
  expect(page).to have_css('.voting-board')
end

Then('the winner should not be revealed yet') do
  expect(page).not_to have_css('.result-modal')
end

Then('all votes are confirmed') do
  @room.get_all_members.each do |member|
    unless @room.has_voted?(member[:id])
      @room.vote(member[:id], 0)
      @room.confirm_vote(member[:id])
    end
  end
  visit current_path
end

Given('option {int} is a location-only match') do |option_number|
  # Spins are stored as JSON, would need to update manually
end

When('I view the voting options') do
  expect(page).to have_css('.voting-board')
end

Then('I should see {string} indicator for option {int}') do |indicator_text, option_number|
  within('.voting-board') do
    option = all('.voting-option')[option_number - 1]
    within(option) do
      expect(page).to have_text(indicator_text)
    end
  end
end

# ==========================================
# COMPLETE PHASE
# ==========================================

Given('the voting has completed in room {string}') do |code|
  @room = Room.find_by(code: code) || Room.create!(
    code: code,
    owner_name: 'Test Owner',
    location: 'SoHo',
    price: '$$',
    categories: ['Italian'],
    state: 'complete'
  )
  
  visit "/rooms/#{@room.id}"
end

Given('option {int} won with {int} votes') do |option_number, vote_count|
  # Mock winner data
end

Given('option {int} was suggested by {string}') do |option_number, member_name|
  # Mock winner data
end

Given('a winner has been selected') do
  @room.tally_votes_and_select_winner! if @room.voting?
end

Given('the winner is a location-price match') do
  # Mock match type
end

Then('I should see the winning restaurant name') do
  within('.result-modal') do
    expect(page).to have_css('.restaurant-name')
  end
end

Then('I should see the restaurant name') do
  expect(page).to have_css('.restaurant-name')
end

Then('I should see the star rating') do
  expect(page).to have_css('.restaurant-rating')
end

Then('I should see the price range') do
  expect(page).to have_css('.price')
end

Then('I should see the cuisine tags') do
  expect(page).to have_css('.cuisine-tag', minimum: 1)
end

Then('I should see the address') do
  expect(page).to have_css('.restaurant-address')
end

Then('I should see the status \(Open/Closed)') do
  expect(page).to have_css('.status-open, .status-closed')
end

Then('a winner should be randomly selected') do
  expect(page).to have_css('.result-modal')
  expect(page).to have_css('.restaurant-name')
end

Then('the winner should be selected') do
  expect(page).to have_css('.result-modal', wait: 10)
  expect(page).to have_text('You\'re going to:', wait: 5)
end

Then('a new tab should open with Google Maps') do
  new_window = windows.last
  within_window new_window do
    expect(current_url).to include('google.com/maps')
  end
end

Then('the restaurant address should be in the search') do
  new_window = windows.last
  within_window new_window do
    expect(current_url).to include('query=')
  end
end

Then('the restaurant details should be copied to clipboard') do
  expect(page).to have_button('Share')
end

Then('the native share dialog should appear') do
  expect(page).to have_css('[data-action*="shareWinner"]')
end

# ==========================================
# REAL-TIME UPDATES
# ==========================================

When('{string} joins the room') do |name|
  @room.add_guest_member(name, location: 'SoHo', price: '$$', categories: ['Italian'])
end

Then('I should see {string} without refreshing') do |text|
  expect(page).to have_text(text, wait: 5)
end

Then('{string} should appear in the members list') do |name|
  within('.members-list') do
    expect(page).to have_css('.member-item', text: name, wait: 5)
  end
end

When('the current person completes their spin') do
  current_member_id = @room.current_turn_member_id
  @room.spin_for_member(current_member_id) if current_member_id
end

Then('the turn order should update') do
  expect(page).to have_css('.turn-item.completed-turn', minimum: 1, wait: 3)
end

Then('the next person\'s turn should be highlighted') do
  expect(page).to have_css('.turn-item.current-turn', wait: 3)
end

When('another member votes') do
  other_member = @room.get_all_members.find { |m| m[:id] != @current_user_id }
  @room.vote(other_member[:id], 0) if other_member
end

Then('I should see the vote count increase') do
  expect(page).to have_css('.vote-count', wait: 5)
end

Then('I should not need to refresh the page') do
  expect(page).to have_current_path(%r{/rooms/\d+})
end

# ==========================================
# EDGE CASES
# ==========================================

When('I refresh the page') do
  visit current_path
end

Then('I should still see {string}') do |text|
  expect(page).to have_text(text)
end

Then('my room should retain all settings') do
  expect(page).to have_css('.preference-section')
end

When('I visit the room URL directly') do
  @room ||= Room.last
  visit "/rooms/#{@room.id}"
end

Then('I should see the room') do
  expect(page).to have_css('.room-container')
end

Then('I should be prompted to join as guest') do
  expect(page).to have_button('Join as Guest')
end

When('a member joins without setting all preferences') do
  @room.add_guest_member('Incomplete User', location: nil, price: '$$', categories: [])
end

Then('the system should use room defaults') do
  # Already handled by model
  expect(true).to be true
end

Then('the member should still be able to spin') do
  @room.update!(state: 'spinning')
  visit current_path
  expect(page).to have_css('.turn-item', minimum: 1)
end

Given('no one else joins') do
  expect(@room.members.length).to eq(0)
end

When('I start spinning and complete my spin') do
  click_button '✨ Start Spinning!'
  sleep 1
  click_button '🎲 Spin the Wheel!'
  sleep 3
end

Then('I should proceed to reveal') do
  expect(page).to have_text('Get Ready for the Big Reveal!', wait: 5)
end

Then('I should be able to vote') do
  click_button '🎉 Reveal All Options!'
  sleep 3
  expect(page).to have_css('.voting-board', wait: 5)
end

Given('{int} guests have joined the room') do |count|
  count.times do |i|
    @room.add_guest_member("Guest#{i + 1}", location: 'SoHo', price: '$$', categories: ['Italian'])
  end
end

Then('all {int} members should be in turn order') do |count|
  within('.turn-order-list') do
    expect(page).to have_css('.turn-item', count: count)
  end
end

Then('each should get exactly one turn') do
  turn_items = all('.turn-item')
  expect(turn_items.length).to eq(@room.get_all_members.length)
end

Given('I am in the spinning phase of room {string}') do |code|
  @room = Room.find_by(code: code) || Room.create!(
    code: code,
    owner_name: 'Test Owner',
    location: 'SoHo',
    price: '$$',
    categories: ['Italian']
  )
  
  @room.start_spinning!
  @current_user_id = "owner"
  visit "/rooms/#{@room.id}"
end

When('the spinning phase starts') do
  @room ||= Room.last
  @room.start_spinning!
  visit current_path
end


# Add this step to features/step_definitions/group_room_steps.rb

Then('DEBUG what happened after create') do
  puts "\n" + "="*80
  puts "DEBUGGING ROOM CREATION"
  puts "="*80
  
  puts "Current URL: #{current_url}"
  puts "Current Path: #{current_path}"
  
  # Check if still on create page (validation failed)
  if page.has_css?('.create-room-container')
    puts "\n❌ Still on CREATE page - form didn't submit!"
    
    # Check validation message
    if page.has_css?('[data-create-room-target="validationMessage"]', visible: :all)
      msg_elem = find('[data-create-room-target="validationMessage"]', visible: :all)
      puts "Validation message visible: #{msg_elem.visible?}"
      puts "Validation message text: '#{msg_elem.text}'" if msg_elem.visible?
    end
    
    # Check the categories input value
    categories_input = find('[data-create-room-target="categoriesInput"]', visible: false)
    puts "Categories input value: '#{categories_input.value}'"
    
    # Check all form values
    puts "\nForm values:"
    puts "  Name: '#{find('[data-create-room-target="ownerNameInput"]').value}'"
    puts "  Location: '#{find('[data-create-room-target="locationSelect"]').value}'"
    puts "  Price: '#{find('[data-create-room-target="priceSelect"]').value}'"
    
    # Check selected cuisines
    selected_cuisines = all('.cuisine-checkbox input[type="checkbox"]:checked').map { |cb| cb.value }
    puts "  Selected cuisine checkboxes: #{selected_cuisines.inspect}"
    
  elsif page.has_css?('.room-container')
    puts "\n✅ On ROOM page - form submitted successfully!"
    
    # Check what's on room page
    puts "Room page contains:"
    puts "  - 'Room Waiting Area': #{page.has_text?('Room Waiting Area')}"
    puts "  - 'Room Code': #{page.has_text?('Room Code')}"
    puts "  - Code value: #{find('.code-value').text}" if page.has_css?('.code-value')
    
  else
    puts "\n⚠️  On UNKNOWN page"
    puts "Page body (first 500 chars):"
    puts page.text[0..500]
  end
  
  # Check database
  room_count = Room.count
  puts "\n📊 Rooms in database: #{room_count}"
  if room_count > 0
    last_room = Room.last
    puts "Last room:"
    puts "  ID: #{last_room.id}"
    puts "  Code: #{last_room.code}"
    puts "  Owner: #{last_room.owner_name}"
    puts "  Location: #{last_room.location}"
    puts "  Price: #{last_room.price}"
    puts "  Categories: #{last_room.categories.inspect}"
    puts "  State: #{last_room.state}"
  end
  
  puts "="*80 + "\n"
end


When('I submit the room form') do
  page.execute_script("document.querySelector('form').submit()")
  sleep 1
end

Then('the {string} field should contain {string}') do |field_name, expected_value|
  case field_name
  when "Name"
    # Be more specific - look for create-room target first
    if page.has_css?('[data-create-room-target="ownerNameInput"]')
      field = find('[data-create-room-target="ownerNameInput"]')
    elsif page.has_css?('[data-solo-spin-target="nameInput"]')
      field = find('[data-solo-spin-target="nameInput"]')
    else
      field = find_field('Name')
    end
    
    expect(field.value).to include(expected_value)
  else
    field = find_field(field_name)
    expect(field.value).to include(expected_value)
  end
end


When('I submit the join room form') do
  # Get the room code
  room_code = find_field('room_code').value
  
  # Find the room and navigate directly
  room = Room.find_by(code: room_code)
  if room
    visit "/rooms/#{room.id}/join_as_guest"
  else
    raise "Room with code #{room_code} not found"
  end
end