# ============================================
# CREATE ROOM FEATURE STEPS
# ============================================

Given "I am on the create room page" do
  visit new_room_path
end

Then /I should see "Create Room"/ do
  expect(page).to have_content("Create Room")
end

Then /I should see an "([^"]*)" input field$/ do |field_name|
  expect(page).to have_field(field_name)
end

Then /the owner name field should display "([^"]*)"/ do |name|
  expect(page).to have_field("Owner Name", with: name)
end

Then /the owner name field should be read-only/ do
  owner_name_field = find("input[name='owner_name']")
  expect(owner_name_field["readonly"]).to eq("readonly")
end

When /I fill in "([^"]*)" with "([^"]*)"/ do |field_name, value|
  fill_in field_name, with: value
end

When /I select "([^"]*)" from "([^"]*)"/ do |option, field|
  select option, from: field
end

When /I click "([^"]*)"/ do |button_text|
  click_on button_text
end

Then /I should see an error message "([^"]*)"/ do |message|
  expect(page).to have_content(message)
end

Then /I should remain on the create room page/ do
  expect(current_path).to eq(new_room_path)
end

Then /the "Create Room" button should be enabled/ do
  button = find_button("Create Room")
  expect(button["disabled"]).to be_nil
end

Then /I should be redirected to the room page/ do
  expect(page).to have_content("Welcome to the Group Room")
end

Then /I should see the room code/ do
  expect(page).to have_css(".room-code")
end

When /I select cuisines "([^"]*)"/ do |cuisines|
  fill_in "Cuisine Preferences", with: cuisines
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
