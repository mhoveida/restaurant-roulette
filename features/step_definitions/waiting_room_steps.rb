Given("a room with code {string} exists with:") do |code, table|
  attrs = table.rows_hash.symbolize_keys

  # Convert comma-separated categories → array
  categories =
    if attrs[:categories].present?
      attrs[:categories].split(",").map(&:strip)
    else
      []
    end

  @room = Room.create!(
    code: code,                     # Override random code
    owner_name: attrs[:owner_name],
    location: attrs[:location],
    price: attrs[:price],
    categories: categories,
    spin_results: []               # Ensure empty spin list
  )
end


# ------------------------------------------
# Guest Join Flow
# ------------------------------------------

When("I visit the join page for room code {string}") do |code|
  room = Room.find_by(code: code)
  raise "Room with code #{code} not found!" unless room

  visit join_as_guest_path(room)
end

When("I enter guest name {string}") do |guest_name|
  fill_in "guest_name", with: guest_name
end

When("I submit the guest join form") do
  click_button "Join Room"
end

Then("I should be on the waiting room page for code {string}") do |code|
  room = Room.find_by(code: code)
  expect(current_path).to eq(room_path(room))
end

# ------------------------------------------
# Spin Button & Spin Room
# ------------------------------------------

Then("I should be on the spin room page") do
  expect(current_path).to match(/\/rooms\/\d+\/group_spin/)
  expect(page).to have_content("Group Spin")
end
