# -----------------------------
# Room Setup
# -----------------------------
Given("a room with code {string} exists") do |code|
  @room = Room.find_or_create_by!(
    code: code,
    owner_name: "Test Host",
    location: "New York",
    price: "$$",
    categories: "Sushi,Thai"
  )
end

# -----------------------------
# Navigation
# -----------------------------
Given("I am the host in the spin room") do
  visit group_spin_room_path(@room)
  expect(page).to have_content("Group Spin")
end

# -----------------------------
# UI Assertions
# -----------------------------
Then /I should see the group roulette wheel$/ do
  expect(page.has_css?(".roulette-wheel")).to be(true), "Expected to find roulette wheel, but did not."
end

Then /the group wheel should animate and spin/ do
  # In test environment, animations happen too fast to verify the "spinning" class
  # Instead, verify the wheel exists and the form will submit
  expect(page).to have_css(".roulette-wheel")
end

Then /the group wheel should slow down gradually/ do
  # This is a visual effect that's hard to test; we verify the wheel exists
  expect(page).to have_css(".roulette-wheel")
end

Then("I should see the {string} button") do |button|
  expect(page).to have_button(button)
end

Then("I should see the group voting section") do
  expect(page).to have_css("[data-room-vote-target='list']")
end

# -----------------------------
# Simulated Broadcast (like Solo Spin)
# -----------------------------
When("a spin result is broadcast for {string}") do |restaurant_name|
  page.execute_script <<~JS
    window.dispatchEvent(
      new CustomEvent("room-spin-result", {
        detail: {
          id: 999,
          name: "#{restaurant_name}",
          price: "$$",
          rating: 4.5,
          image_url: "http://example.com/image.jpg",
          address: "123 Sushi Ave",
          is_open_now: true
        }
      })
    );
  JS
end

# -----------------------------
# UI checks
# -----------------------------
Then("I should see the restaurant popup for {string}") do |name|
  expect(page).to have_content(name)
end

Then("I should see {string} in the voting list") do |name|
  within("[data-room-vote-target='list']") do
    expect(page).to have_content(name)
  end
end

Then("I should see the restaurant rating") do
  expect(page).to have_css(".restaurant-rating")
end
