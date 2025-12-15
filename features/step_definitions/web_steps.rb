# features/step_definitions/web_steps.rb

# ============================================
# SETUP
# ============================================

Given "I am on the home page" do
  visit root_path
end

Given "I am not logged in" do
  logout(:user)
  visit root_path
end

# ADDED: This handles the navigation that was previously ambiguous
Given "I am on the solo spin page" do
  visit solo_spin_path
end

# ============================================
# ACTIONS
# ============================================

# This smart step handles both buttons and links
When(/I click "(.*)"/) do |text|
  # Try button first (most common) - ADD match: :first
  if page.has_button?(text, wait: 2)
    click_button text, match: :first  # <-- ADD match: :first here
  # Then try link
  elsif page.has_link?(text, wait: 2)
    click_link text, match: :first  # <-- ADD match: :first here
  # Then try any element with data-action (Stimulus buttons)
  elsif page.has_css?('[data-action]', text: text, wait: 2)
    find('[data-action]', text: text, match: :first).click
  # Last resort - any clickable element
  elsif page.has_css?('button, a, [role="button"]', text: text, wait: 2)
    find('button, a, [role="button"]', text: text, match: :first).click
  else
    raise Capybara::ElementNotFound, "Could not find button, link, or clickable element: #{text}"
  end

  sleep 0.5
end

Then('I should be redirected to the home page') do
  expect(current_path).to eq(root_path)
end

When "I click on the user profile icon" do
  find("span.profile-email").click
end

When "I click 'Join Room' without entering a code" do
  click_on "Join Room"
end

When "I visit the solo spin page" do
  visit solo_spin_path
end

# ============================================
# ASSERTIONS
# ============================================
Then("I should see a {string} button") do |text|
  # This matches links styled as buttons OR actual buttons
  expect(page).to have_selector(:link_or_button, text)
end

Then (/^I should see "(.*)"$/) do |text|
  page_text = page.text(:all)
  expect(page_text).to include(text), "Expected to find text '#{text}' on the page"
end

# Auth & General
Then('I should see {string} tab') do |text|
  expect(page).to have_css('.auth-tab-button', text: text, exact_text: true)
end

Then('I should see {string} heading') do |text|
  expect(page).to have_css('h1.auth-title', text: text)
end

Then('I should see {string} button') do |text|
  expect(page).to have_button(text)
end

Then('I should see {string} input field') do |field_name|
  expect(page).to have_field(field_name)
end

Then('I should see {string} button instead of my name') do |button_text|
  has_button = page.has_button?(button_text) || page.has_link?(button_text)
  expect(has_button).to be true
  expect(page).not_to have_css('.profile-email')
end

Then /I should see an "(.*)" input field/ do |field_name|
  expect(page.has_field?(field_name)).to be(true), "Expected to find field '#{field_name}', but did not."
end

Then /I should see the roulette wheel graphic/ do
  expect(page.has_css?('#roulette-wheel-graphic')).to be(true), "Expected to find CSS '#roulette-wheel-graphic', but did not."
end

# Solo Spin specific
Then /I should be on the solo spin page/ do
  expect(page.has_content?("Solo Spin")).to be(true), "Expected to be on the solo spin page, but was not."
end

Then "I should be on the home page" do
  expect(current_path).to eq(root_path)
end

Then /I should see a name input field/ do
  expect(page.has_field?("Name")).to be(true)
end

Then /I should see a location input field with search icon/ do
  expect(page.has_field?("Location")).to be(true)
  expect(page.has_content?("📍")).to be(true)
end

Then /I should see a price range dropdown/ do
  expect(page.has_field?("Price Range")).to be(true)
end

Then /I should see a cuisine preferences dropdown/ do
  expect(page.has_field?("Cuisine Preferences")).to be(true)
end

Then /I should see the roulette wheel$/ do
  expect(page.has_css?("#roulette-wheel")).to be(true)
end

Then /the name field should display "(.*)"/ do |name|
  expect(page.has_field?("Name", with: name)).to be(true)
end

Then /the name field should be read-only/ do
  name_field = find("input[name='name']")
  expect(name_field["readonly"]).to eq("readonly")
end

When /I select "([^"]*)" from "([^"]*)"/ do |option, field|
  select option, from: field
end

When /I select cuisines "([^"]*)"/ do |cuisines|
  fill_in "Cuisine Preferences", with: cuisines
end

Then /all required fields should be filled/ do
  name_field = if page.has_field?("name")
    find("input[name='name']")
  else
    find("input[name='owner_name']")
  end
  expect(name_field.value).not_to be_empty
end

Then /the "([^"]*)" button should be enabled/ do |button_text|
  button = find_button(button_text)
  expect(button["disabled"]).to be_nil
end

Then /the wheel should not spin/ do
  wheel = find("#roulette-wheel")
  expect(wheel["class"]).not_to include("spinning")
end

Then /I should be on the create room page/ do
  expect(page.has_content?("Create a Group Room")).to be(true)
end

Then "I should be redirected to the group room page" do
  # Now logged-in users go to preferences first, then to room
  expect(page.current_path.start_with?("/rooms/") &&
         (page.current_path.include?("/join_as_guest") ||
          page.current_path.match?(/\/rooms\/\d+$/))).to be true
end

Then /I should be redirected to the join room page/ do
  expect(page.has_content?("Set your preferences")).to be(true)
end

Then /I should remain on the home page/ do
  expect(current_path).to eq(root_path)
end

Then /the room code field should remain filled with "(.*)"/ do |value|
  expect(page.has_field?("Enter Room Code", with: value)).to be(true)
end

Then /I should see a "(.*)" button in the header/ do |button_text|
  within("header") do
    expect(page.has_link?(button_text) || page.has_button?(button_text)).to be(true)
  end
end

Then "I should see a dropdown menu with profile options" do
  expect(page).to have_css(".dropdown-menu", visible: true, wait: 5)
end
