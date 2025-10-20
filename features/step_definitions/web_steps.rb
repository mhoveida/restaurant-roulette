Given "I am on the home page" do
  visit root_path
end

# This checks for any text on the page
Then /I should see "(.*)"/ do |text|
  expect(page).to have_content(text)
end

# This checks for buttons with specific text
Then /I should see a "(.*)" button/ do |button_text|
  expect(page).to have_button(button_text)
end

# This checks for the form fields
Then /I should see a join room form/ do
  expect(page).to have_field("Enter Room Code")
  expect(page).to have_button("Join Room")
end

# This checks for the placeholder <div> we made
Then /I should see the roulette wheel graphic/ do
  expect(page).to have_css('#roulette-wheel-graphic')
end
