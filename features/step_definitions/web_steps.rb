# ============================================
# BACKGROUND
# ============================================



# ============================================
# GIVEN STEPS - Setup
# ============================================

Given "I am on the home page" do
  visit root_path
end

Given "I am not logged in" do
  logout(:user)
  visit root_path
end

Given /a room exists with code "(.*)"/ do |code|
  FactoryBot.create(:room, code: code)
end


# ============================================
# WHEN STEPS - Actions
# ============================================

When /I click "(.*)"/ do |link_or_button_text|
  # Try to click a button first (within the visible form), then try a link
  begin
    # Try to click visible form first
    visible_form = find('form', visible: true)
    within(visible_form) do
      click_button link_or_button_text
    end
  rescue Capybara::ElementNotFound
    # No visible form, try clicking anywhere
    begin
      click_button link_or_button_text
    rescue Capybara::ElementNotFound
      click_link link_or_button_text
    end
  end
end

When /I fill in "(.*)" with "(.*)"/ do |field_name, value|
  fill_in field_name, with: value
end

When "I click on the user profile icon" do
  find("span.profile-email").click
end

When "I click 'Join Room' without entering a code" do
  click_on "Join Room"
end


# ============================================
# THEN STEPS - Assertions
# ============================================

Then (/^I should see "(.*)"$/) do |text|
  # Check if text exists anywhere on the page (including hidden content)
  page_text = page.text(:all)
  expect(page_text).to include(text), "Expected to find text '#{text}' on the page"
end

Then /I should see a "(.*)" button$/ do |link_or_button_text|
  has_button = page.has_link?(link_or_button_text) || page.has_button?(link_or_button_text) ||
               page.has_link?(link_or_button_text, visible: :all) || page.has_button?(link_or_button_text, visible: :all)
  expect(has_button).to be(true), "Expected to find link or button '#{link_or_button_text}', but did not."
end

Then /I should see an "(.*)" input field/ do |field_name|
  expect(page.has_field?(field_name)).to be(true), "Expected to find field '#{field_name}', but did not."
end

Then /I should see the roulette wheel graphic/ do
  expect(page.has_css?('#roulette-wheel-graphic')).to be(true), "Expected to find CSS '#roulette-wheel-graphic', but did not."
end

Then /I should be on the solo spin page/ do
  expect(page.has_content?("Solo Spin")).to be(true), "Expected to be on the solo spin page, but was not."
end

Given "I am on the solo spin page" do
  visit solo_spin_path
end

Then /I should see a name input field/ do
  expect(page.has_field?("Name")).to be(true), "Expected to find 'Name' field, but did not."
end

Then /I should see a location input field with search icon/ do
  expect(page.has_field?("Location")).to be(true), "Expected to find 'Location' field, but did not."
  expect(page.has_content?("📍")).to be(true), "Expected to find search icon, but did not."
end

Then /I should see a price range dropdown/ do
  expect(page.has_field?("Price Range")).to be(true), "Expected to find 'Price Range' dropdown, but did not."
end

Then /I should see a cuisine preferences dropdown/ do
  expect(page.has_field?("Cuisine Preferences")).to be(true), "Expected to find 'Cuisine Preferences' field, but did not."
end

Then /I should see the roulette wheel$/ do
  expect(page.has_css?("#roulette-wheel")).to be(true), "Expected to find roulette wheel, but did not."
end

Then /the name field should display "(.*)"/ do |name|
  expect(page.has_field?("Name", with: name)).to be(true), "Expected name field to display '#{name}', but did not."
end

Then /the name field should be read-only/ do
  name_field = find("input[name='name']")
  expect(name_field["readonly"]).to eq("readonly"), "Expected name field to be read-only, but was not."
end

When /I select "([^"]*)" from "([^"]*)"/ do |option, field|
  select option, from: field
end

When /I select cuisines "([^"]*)"/ do |cuisines|
  fill_in "Cuisine Preferences", with: cuisines
end

Then /all required fields should be filled/ do
  # Try to find either 'name' (solo_spin) or 'owner_name' (create_room)
  name_field = if page.has_field?("name")
    find("input[name='name']")
  else
    find("input[name='owner_name']")
  end
  location_field = find("input[name='location']")
  price_field = find("select[name='price']")
  cuisine_field = find("input[name='categories']")

  expect(name_field.value).not_to be_empty, "Name field should be filled"
  expect(location_field.value).not_to be_empty, "Location field should be filled"
  expect(price_field.value).not_to be_empty, "Price field should be filled"
  expect(cuisine_field.value).not_to be_empty, "Cuisine field should be filled"
end

Then /the "([^"]*)" button should be enabled/ do |button_text|
  button = find_button(button_text)
  expect(button["disabled"]).to be_nil, "Expected button to be enabled, but was disabled."
end

Then /the wheel should not spin/ do
  wheel = find("#roulette-wheel")
  expect(wheel["class"]).not_to include("spinning"), "Expected wheel not to spin, but it did."
end

Then /I should be on the create room page/ do
  expect(page.has_content?("Create a Group Room")).to be(true), "Expected to be on the create room page, but was not."
end

Then /I should be redirected to the group room page/ do
  expect(page.has_content?("Room Waiting Area")).to be(true), "Expected to be on the group room page, but was not."
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

Then "I should see a dropdown menu with profile options" do
  expect(page).to have_css(".dropdown-menu", visible: true)
end
