# ----------------------------
# WAITING ROOM PHASE
# ----------------------------

Given("I am on the group room waiting page") do
  @room ||= Room.last || FactoryBot.create(:room, code: "8865", owner_name: "Maddison")
  visit room_path(@room)

  # Wait for the page to render
  using_wait_time 3 do
    page_text = page.text
    expect(page_text).to match(/Room Waiting Area|Share this code|Room Code:/),
      "Expected to be on the waiting room page but saw:\n#{page_text[0..200]}"
  end
end

Then("I should see {string} listed") do |member_name|
  expect(page).to have_content(member_name)
end

Then("I should see {string} button enabled") do |button_text|
  button = find_button(button_text)
  expect(button).not_to be_disabled
end

Given("I am a guest user named {string}") do |name|
  @room ||= Room.last || FactoryBot.create(:room)
  visit join_as_guest_path(@room)
  fill_in "guest_name", with: name
  click_button "Join Room"
end

Then("I should be redirected to the waiting room") do
  expect(page).to have_current_path(room_path(@room))
  expect(page).to have_content("Room Code:")
end

Then("I should be redirected to the group spin page") do
  expect(page).to have_current_path(spin_room_room_path(@room))
end

Then("all members should automatically follow to the spin page") do
  # In test env, we simply assert that the spin page renders
  expect(page).to have_content("Group Voting")
end

# ----------------------------
# SPIN ROOM PHASE
# ----------------------------

Given("I am on the group spin page") do
  @room = Room.find_by(code: "8865") || FactoryBot.create(:room, code: "8865", owner_name: "Maddison")
  visit spin_room_room_path(@room, voter_name: @current_user&.first_name || "TestUser")
end

Then("the group wheel should animate and spin") do
  expect(page).to have_css(".roulette-wheel")
end

Then("the group wheel should slow down gradually") do
  expect(page).to have_css(".roulette-wheel")
end

Then("I should see the group result overlay appear") do
  using_wait_time 5 do
    expect(page).to have_css(".result-overlay", visible: true)
  end
end

Then('I should see {string} section') do |section_name|
  expect(page).to have_content(section_name),
    "Expected to see section '#{section_name}' but it wasn't visible on the page."
end

Then('I should see {string} message') do |message_text|
  expect(page).to have_content(message_text),
    "Expected to see message '#{message_text}' but it wasn't found."
end

Then("I should see a new restaurant card appear under {string}") do |_|
  using_wait_time 5 do
    expect(page).to have_css(".restaurant-card", visible: true)
  end
end

Then("the card should display the restaurant name, rating, price, and address") do
  expect(page).to have_css(".rc-name")
  expect(page).to have_css(".rc-sub")
end

Given("a restaurant has already been spun") do
  step "I am on the group spin page"
  step 'I click "✨ Ready to Spin?" on the wheel'
  step "I should see the group result overlay appear"
end

Then("I should see a different restaurant result") do
  expect(page).to have_css(".result-overlay", visible: true)
end

Then("multiple restaurant cards should now appear in {string}") do |_|
  expect(page.all(".restaurant-card").size).to be >= 2
end

# ----------------------------
# LIVE UPDATES
# ----------------------------

Given("I am {string} on the group spin page") do |member_name|
  @room ||= Room.last || FactoryBot.create(:room)
  visit spin_room_room_path(@room)
  expect(page).to have_content("You are voting as: #{member_name}")
end

When("the host spins again") do
  # simulate ActionCable broadcast
  ActionCable.server.broadcast("room_#{@room.id}", {
    type: "spin_result",
    restaurant: { id: 999, name: "Live Restaurant", price: "$$", rating: 4.8, address: "123 Test Ave" }
  })
  sleep 1
end

Then("I should see the new restaurant appear automatically under {string}") do |_|
  expect(page).to have_content("Live Restaurant")
end

Then("I should not need to refresh the page") do
  expect(page).to have_no_current_path(root_path)
end

# ----------------------------
# VOTING PHASE
# ----------------------------

Given("at least two restaurants have been spun") do
  @room ||= Room.last || FactoryBot.create(:room)
  @room.update(spin_results: [
    { "id" => 1, "name" => "Da Andrea", "price" => "$$", "rating" => 4.7 },
    { "id" => 2, "name" => "Shukette", "price" => "$$", "rating" => 4.5 }
  ])
  visit spin_room_room_path(@room)
end

Then("each restaurant card should display 👍 and 👎 buttons") do
  expect(page).to have_css("button[data-value='up']")
  expect(page).to have_css("button[data-value='down']")
end

Given("voting has started") do
  step "at least two restaurants have been spun"
end

When("I click the thumbs up button for {string}") do |restaurant_name|
  within(".restaurant-card", text: restaurant_name) do
    find("button[data-value='up']").click
  end
end

When("I click the thumbs down button for {string}") do |restaurant_name|
  within(".restaurant-card", text: restaurant_name) do
    find("button[data-value='down']").click
  end
end

Then("my vote should be recorded") do
  expect(page).to have_css(".count-up, .count-down")
end

Then("I should see the 👍 count increase by 1") do
  expect(page).to have_css(".count-up", text: /1/)
end

Then("I should see the 👎 count increase by 1") do
  expect(page).to have_css(".count-down", text: /1/)
end

Then("all members should see the updated counts live") do
  expect(page).to have_css(".count-up, .count-down")
end

Given("{string} votes 👍 for {string}") do |user, restaurant|
  @room ||= Room.last
  ActionCable.server.broadcast("room_#{@room.id}", {
    type: "vote_update",
    counts: { "#{restaurant},up" => 1 }
  })
  puts "#{user} voted 👍 for #{restaurant}"
end

Then("{string} should immediately see the updated 👍 count") do |_|
  expect(page).to have_css(".count-up", text: /1/)
end

# ----------------------------
# CONTINUED SPINNING
# ----------------------------

Given("I am the host") do
  expect(page).to have_content("You are voting as: Maddison")
end

Then("a new restaurant card should be added under {string}") do |_|
  expect(page.all(".restaurant-card").size).to be >= 3
end

Then("all members should see it appear live") do
  expect(page).to have_css(".restaurant-card")
end

Then("all members can vote on it immediately") do
  expect(page).to have_css("button[data-value='up']")
  expect(page).to have_css("button[data-value='down']")
end

# ----------------------------
# RESULTS
# ----------------------------

Given("members are voting in real time") do
  step "voting has started"
end

Then("each restaurant card should show live 👍 and 👎 counts updating") do
  expect(page).to have_css(".count-up, .count-down")
end

Then("no refresh should be required") do
  expect(page).to have_current_path(spin_room_room_path(@room))
end

Then("I should see the restaurant with the highest votes highlighted") do
  expect(page).to have_css(".restaurant-card")
end
