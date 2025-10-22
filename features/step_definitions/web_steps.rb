# --- Page Navigation ---

Given "I am on the home page" do
  visit root_path
end

When /I click "(.*)"/ do |link_or_button_text|
  click_on link_or_button_text
end

When /I fill in "(.*)" with "(.*)"/ do |field_name, value|
  fill_in field_name, with: value
end

# --- Authentication Steps ---

Given /I am logged in as "(.*)"/ do |name|
  # 'create' makes and saves the user in the test database
  user = FactoryBot.create(:user, email: "#{name.downcase}@example.com")
  login_as(user)
end

Given "I am not logged in" do
  # Use Warden's logout helper to ensure no user is logged in
  logout(:user)
  visit root_path
end

# --- Assertion Steps ---

Then /I should see "(.*)"/ do |text|
  expect(page).to have_content(text)
end

Then /I should see a "(.*)" button/ do |button_text|
  expect(page).to have_button(button_text)
end

Then /I should see an "(.*)" input field/ do |field_name|
  expect(page).to have_field(field_name)
end

Then /I should see the roulette wheel graphic/ do
  expect(page).to have_css('#roulette-wheel-graphic')
end

Then /I should be on the solo spin page/ do
  expect(page).to have_content("This is the Solo Spin page")
end

Then /I should be on the create room page/ do
  expect(page).to have_content("This is the Create Room page")
end

Then /I should be redirected to the group room page/ do
  expect(page).to have_content("Welcome to the Group Room")
end

Then /I should be redirected to the join room page/ do
  expect(page).to have_content("Join this room")
end

Then /I should remain on the home page/ do
  expect(current_path).to eq(root_path)
end

Then /the room code field should remain filled with "(.*)"/ do |value|
  expect(page).to have_field("Enter Room Code", with: value)
end

# --- Room-Specific Steps ---

When "I click 'Join Room' without entering a code" do
  click_on "Join Room"
end

# --- Pending Steps ---

Given /a room exists with code "(.*)"/ do |code|
  # This will be implemented when we build the Room model
  pending "Step not defined: Create Room model and factory"
end

When "I click on the user profile icon" do
  pending "Step not defined: Implement profile dropdown JavaScript/CSS"
end

Then "I should see a dropdown menu with profile options" do
  pending "Step not defined: Implement profile dropdown HTML"
end
