# ============================================
# GROUP SPIN FEATURE STEPS
# ============================================


Then /^I should see a spinning wheel$/ do
  # Check for spinning wheel or button to initiate spin
  has_wheel = page.has_button?("Ready to Spin?") || page.has_css?(".wheel") || page.has_css?(".roulette") || page.has_css?(".spinner")
  expect(has_wheel).to be_truthy
end

Then /^the wheel should generate a restaurant result$/ do
  # After spinning, the page should show the room with a popup with restaurant result
  # Check for restaurant result or remain on room page
  expect(
    page.has_css?(".restaurant-name", wait: 5) ||
    page.has_css?(".restaurant-result", wait: 5)
  ).to be_truthy
end

Then /^I should be redirected to the room$/ do
  expect(page).to have_content("Room Waiting Area")
end

Given /^I have created another room$/ do
  @room2 = create(:room)
end

Then /^the room codes should be different$/ do
  expect(@room.code).not_to eq(@room2.code)
end
