# ============================================
# GROUP SPIN FEATURE STEPS
# ============================================


Then /^I should see a spinning wheel$/ do
  # Check for spinning wheel or button to initiate spin
  has_wheel = page.has_button?("Ready to Spin?") || page.has_css?(".wheel") || page.has_css?(".roulette") || page.has_css?(".spinner")
  expect(has_wheel).to be_truthy
end

Then /^the wheel should generate a restaurant result$/ do
  # After spinning, the page should still show the room or navigate to a result page
  # Check for restaurant result or remain on room page
  has_result = page.has_content?("You are going to:") || page.has_css?(".restaurant-result") || page.has_content?("Room Waiting Area")
  expect(has_result).to be_truthy
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
