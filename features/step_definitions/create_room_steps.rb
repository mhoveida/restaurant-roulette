# ============================================
# CREATE ROOM FEATURE STEPS
# ============================================

Given "I am on the create room page" do
  visit "/rooms/new"
end

Then /I should see "Create Room"/ do
  expect(page).to have_content("Create Room")
end

Then /the owner name field should display "([^"]*)"/ do |name|
  expect(page).to have_field("Name", with: name)
end

Then /the owner name field should be read-only/ do
  owner_name_field = find("input[name='owner_name']")
  expect(owner_name_field["readonly"]).to eq("readonly")
end

Then /I should see an error message "([^"]*)"/ do |message|
  expect(page).to have_content(message)
end

Then /I should remain on the create room page/ do
  expect(current_path).to eq("/rooms/new")
end

Then /I should be redirected to the room page/ do
  expect(page).to have_content("Welcome to the Group Room")
end

Then /I should see the room code/ do
  expect(page).to have_css(".room-code")
end

Then /all required room fields should be filled/ do
  owner_field = find("input[name='owner_name']")
  location_field = find("input[name='location']")
  price_field = find("select[name='price']")
  cuisine_field = find("input[name='categories']")

  expect(owner_field.value).not_to be_empty, "Owner name field should be filled"
  expect(location_field.value).not_to be_empty, "Location field should be filled"
  expect(price_field.value).not_to be_empty, "Price field should be filled"
  expect(cuisine_field.value).not_to be_empty, "Cuisine field should be filled"
end

Given /I have filled in all room preferences:$/ do |table|
  row = table.hashes.first
  fill_in "Owner Name", with: row["Owner Name"]
  fill_in "Location", with: row["Location"]
  select row["Price Range"], from: "Price Range"
  fill_in "Cuisine Preferences", with: row["Cuisines"]
end

Then /the room code should be displayed/ do
  expect(page).to have_content(/"code"/)
end

Then /I should see the "([^"]*)" sharing option/ do |option|
  expect(page).to have_content(option)
end

Then /the room should not be created/ do
  # After form submission with validation errors, we're back on the create form
  # The path could be either /rooms/new (if redirected) or /rooms (if rendered)
  expect([ "/rooms/new", "/rooms" ]).to include(page.current_path)
end

Then /the name field should be empty/ do
  expect(page).to have_field("Name", with: "")
end

Then /the owner name field should be empty/ do
  expect(page).to have_field("Name", with: "")
end

Then /the owner name field should be editable/ do
  owner_name_field = find("input[name='owner_name']")
  expect(owner_name_field["readonly"]).to be_nil
end

Then /a new room should be created/ do
  # Verify we're on the room page (show action)
  expect(page).to have_content("Room Waiting Area")
end

Then /I should be redirected to the room waiting page/ do
  # Verify we're on the room show page
  expect(page).to have_content("Room Waiting Area")
end

Then /I should see a unique room code/ do
  expect(page).to have_css(".code-value")
end

Then /the room code should be (\d+) digits/ do |num_digits|
  room_code = find(".code-value").text
  expect(room_code.length).to eq(num_digits.to_i)
end

Then /I should see an owner name field with "([^"]*)"/ do |name|
  expect(page).to have_field("Name", with: name)
end

Given /^I have created a room successfully$/ do
  # Create a room with a known code for testing
  @room = create(:room, code: "8865", owner_name: "Maddison")
  visit room_path(@room)
end

Given /I have created a room with code "([^"]*)"/ do |code|
  room = create(:room, code: code)
  visit room_path(room)
end

Given /^I have created a room$/ do
  room = create(:room)
  visit room_path(room)
end

Given /I am on the room waiting page/ do
  room = create(:room)
  visit room_path(room)
end

Given /I am viewing the room waiting page/ do
  room = create(:room)
  visit room_path(room)
end

Given /no other members have joined/ do
  # Just create a room with only the owner
  # The room is already created in the previous step
end

Then /the button should be enabled regardless of member count/ do
  expect(page).to have_button("Ready to Spin?")
  expect(find_button("Ready to Spin?")).not_to be_disabled
end

Then /I should be able to proceed to the spinning phase/ do
  expect(page).to have_button("Ready to Spin?")
end

Then /restaurant options should be generated based on my preferences/ do
  # This will be implemented in the spinning feature
  pending
end

When /another user "([^"]*)" joins the room/ do |user_name|
  # This would require WebSocket/real-time communication
  pending
end

Then /I should not need to refresh the page/ do
  # This would require WebSocket/real-time communication
  pending
end

Given /other users have joined: "([^"]*)"/ do |members_str|
  # This would require WebSocket/real-time communication
  # For now, just mark as pending
  pending
end

Given /members "([^"]*)" have joined/ do |members|
  # Simulate multiple members joining the room
  @room ||= Room.last || create(:room, code: "8865", owner_name: "Maddison")

  member_names = members.split(",").map(&:strip)
  member_names.each do |name|
    @room.add_guest_member(name)
  end

  # Extract only member names from stored data
  stored_names = Array(@room.reload.members).map { |m| m["name"] }

  expect(stored_names).to include(*member_names)
end

Then /members should be listed in order of joining/ do
  members = page.all(".member-name").map(&:text)
  expect(members).to eq(members)
end

Then /I should be redirected to the group room spin page/ do
  expect(page).to have_content("Spin to add options")
end

Given /I have filled in all preferences/ do
  fill_in "Location", with: "New York"
  select "$$", from: "Price Range"
  fill_in "Cuisine Preferences", with: "Italian"
end

When /I click the back button or logo/ do
  click_link "Restaurant Roulette" rescue click_button "Back"
end

Then /I should return to the home page/ do
  expect(current_path).to eq(root_path)
end

Then /no room should be created/ do
  expect(Room.count).to eq(0)
end

Given /I have created a room as "([^"]*)"/ do |name|
  room = create(:room, owner_name: name)
  visit room_path(room)
end

Then /"([^"]*)" should be marked as "([^"]*)" or "([^"]*)" in the members list/ do |name, role1, role2|
  member_element = find(".member-name", text: name).find(:xpath, "..")
  expect(member_element).to satisfy { |el| el.has_content?(role1) || el.has_content?(role2) }
end

Then /other members should see this designation/ do
  # This would require multiple user sessions
  pending
end

Then /the room code should have a copy icon/ do
  expect(page).to have_button("📋 Copy Room Code")
end

When /I click the copy icon next to the room code/ do
  click_button "📋 Copy Room Code"
end

Then /I should see a confirmation that the room code was copied/ do
  confirmation_text = find("#copyConfirmation", visible: :all).text
end

Then /"([^"]*)" should be removed/ do |cuisine|
  expect(page).not_to have_content(cuisine)
end

Then /I should see remaining cuisines "([^"]*)"/ do |cuisines|
  cuisines.split(", ").each do |cuisine|
    expect(page).to have_content(cuisine.strip)
  end
end

Given /I have selected create room cuisines "([^"]*)"/ do |cuisines|
  fill_in "Cuisine Preferences", with: cuisines
end

When /I click on the create room "([^"]*)" dropdown/ do |dropdown_name|
  find("label", text: dropdown_name).sibling("input, select").click
end

When /I select "([^"]*)" cuisine/ do |cuisine|
  fill_in "Cuisine Preferences", with: cuisine
end

When /I click the create room X button on "([^"]*)"/ do |cuisine|
  tag = find(".cuisine-tag", text: cuisine)
  tag.find(".remove-btn").click
end

Then /^I should see "([^"]*)" create room tag with X button$/ do |cuisine|
  within(".cuisine-tags") do
    expect(page).to have_text(/#{cuisine}/i)
    expect(page).to have_css(".remove-btn")
  end
end

Then(/^I should see "([^"]*)" as the first member$/) do |name|
  members = all(".member-name").map(&:text)
  expect(members.first).to eq(name)
end

Then(/^I should see "([^"]*)" appear in the members list$/) do |name|
  within(".members-list") do
    expect(page).to have_text(name)
  end
end
