# ============================================
# GROUP ROOM VOTING FEATURE STEPS
# ============================================

Given("I am on the group spin page") do
  @room ||= create(:room, code: "8865", owner_name: "Maddison")
  visit room_path(@room)
  expect(page).to have_content("Spin to add options")
end

Then("I should be redirected to the group spin page") do
  expect(page).to have_content("Spin to add options")
  expect(page).to have_selector("canvas") # the roulette wheel
end

Then("the spin button on the wheel should be visible") do
  expect(page).to have_button("Spin")
end

Then("I should see {string} section") do |section|
  expect(page).to have_content(section)
end

Given("no options have been added yet") do
  expect(page).not_to have_css(".restaurant-card")
end

Then("the restaurant should be added to the voting board") do
  expect(page).to have_css(".restaurant-card", count: 1)
end

Given("the owner has spun once") do
  step "I am on the group spin page"
  click_button "Spin"
  sleep 2 # give ActionCable/JS some time if running headless
end

Then("I should see {string} label") do |label|
  expect(page).to have_content(label)
end

Then("I should see the rating {string} with stars") do |rating|
  expect(page).to have_content(rating)
  expect(page).to have_css(".stars")
end

Then("I should see the address {string}") do |address|
  expect(page).to have_content(address)
end

Then("I should see the price range {string}") do |price|
  expect(page).to have_content(price)
end
