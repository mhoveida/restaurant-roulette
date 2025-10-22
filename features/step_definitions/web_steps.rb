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
  user = FactoryBot.create(:user, email: "#{name.downcase}@example.com")
  login_as(user)
end

Given "I am not logged in" do
  logout(:user)
  visit root_path
end

# --- ASSERTION STEPS (CORRECTED) ---

Then /I should see "(.*)"/ do |text|
  expect(page.has_content?(text)).to be(true), "Expected to find text '#{text}', but did not."
end

Then /I should see a "(.*)" button$/ do |link_or_button_text|
  expect(page.has_link?(link_or_button_text) || page.has_button?(link_or_button_text)).to be(true), "Expected to find link or button '#{link_or_button_text}', but did not."
end

Then /I should see an "(.*)" input field/ do |field_name|
  expect(page.has_field?(field_name)).to be(true), "Expected to find field '#{field_name}', but did not."
end

Then /I should see the roulette wheel graphic/ do
  expect(page.has_css?('#roulette-wheel-graphic')).to be(true), "Expected to find CSS '#roulette-wheel-graphic', but did not."
end

Then /I should be on the solo spin page/ do
  expect(page.has_content?("This is the Solo Spin page")).to be(true), "Expected to be on the solo spin page, but was not."
end

Then /I should be on the create room page/ do
  expect(page.has_content?("This is the Create Room page")).to be(true), "Expected to be on the create room page, but was not."
end

Then /I should be redirected to the group room page/ do
  expect(page.has_content?("Welcome to the Group Room")).to be(true), "Expected to be on the group room page, but was not."
end

Then /I should be redirected to the join room page/ do
  expect(page.has_content?("Join this room")).to be(true), "Expected to be on the join room page, but was not."
end

Then /I should remain on the home page/ do
  expect(current_path).to eq(root_path)
end

Then /the room code field should remain filled with "(.*)"/ do |value|
  expect(page.has_field?("Enter Room Code", with: value)).to be(true), "Expected 'Enter Room Code' to be filled with '#{value}', but was not."
end

Then /I should see a "(.*)" button in the header/ do |button_text|
  within("header") do
    expect(page.has_link?(button_text) || page.has_button?(button_text)).to be(true), "Expected to find link or button '#{button_text}' in the header, but did not."
  end
end

# --- Room-Specific Steps ---

When "I click 'Join Room' without entering a code" do
  click_on "Join Room"
end

# --- Pending Steps ---

Given /a room exists with code "(.*)"/ do |code|
  pending "Step not defined: Create Room model and factory"
end

When "I click on the user profile icon" do
  pending "Step not defined: Implement profile dropdown JavaScript/CSS"
end

Then "I should see a dropdown menu with profile options" do
  pending "Step not defined: Implement profile dropdown HTML"
end