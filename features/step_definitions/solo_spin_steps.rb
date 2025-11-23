# features/step_definitions/solo_spin_steps.rb

# ==========================================
# UI VERIFICATION
# ==========================================

Then("I should see a {string} input field") do |field_name|
  case field_name
  when "Name"
    expect(page).to have_css("input[data-solo-spin-target='nameInput']")
  else
    expect(page).to have_field(field_name)
  end
end

Then("I should see a {string} dropdown") do |label_text|
  expect(page).to have_content(label_text)
  expect(page).to have_css('select')
end

Then("I should see the cuisine selection grid") do
  expect(page).to have_css('.cuisines-grid')
end

Then("the {string} field should contain {string}") do |field_name, value|
  input = find("input[data-solo-spin-target='nameInput']")
  expect(input.value).to eq value
end

Then("the {string} field should be read-only") do |field_name|
  input = find("input[data-solo-spin-target='nameInput']")
  expect(input[:readonly]).to be_truthy
end

# ==========================================
# INTERACTION
# ==========================================

When("I fill in {string} with {string}") do |label, value|
  if label == "Your Name" || label == "Name"
    find("input[data-solo-spin-target='nameInput']").set(value)
  else
    fill_in label, with: value
  end
end

When("I select {string} from the {string} dropdown") do |option_text, label|
  if label == "Neighborhood"
    dropdown = find("select[data-solo-spin-target='locationSelect']")
    using_wait_time(5) do 
      dropdown.find(:option, option_text).select_option
    end
  elsif label == "Price Range"
    dropdown = find("select[data-solo-spin-target='priceSelect']")
    dropdown.find(:option, option_text).select_option
  else
    select option_text, from: label
  end
end

When("I select {string} from the cuisine grid") do |cuisine_name|
  using_wait_time(5) do
    find('.cuisines-grid label', text: cuisine_name).click
  end
end

# Note: "I click {string}" removed to avoid conflict with web_steps.rb

# ==========================================
# VALIDATION & ANIMATION
# ==========================================

Then("I should see a validation message {string}") do |message|
  expect(page).to have_css('.validation-message', text: message, visible: true)
end

Then("the wheel should spin") do
  expect(page).to have_css('#roulette-wheel.spinning', wait: 2)
end

Then("the wheel should not be spinning") do
  expect(page).not_to have_css('#roulette-wheel.spinning')
end

# ==========================================
# RESULTS (MODAL)
# ==========================================

Then("I should see the result modal") do
  using_wait_time(6) do
    expect(page).to have_css('.result-modal', visible: true)
  end
end

Then("I should see the restaurant name {string}") do |name|
  within('.result-modal') do
    expect(page).to have_css('.restaurant-name', text: name)
  end
end

Then("I should see the restaurant name") do
  within('.result-modal') do
    expect(page).to have_css('.restaurant-name')
    expect(find('.restaurant-name').text).not_to be_empty
  end
end

Then("I should see the star rating") do
  within('.result-modal') do
    expect(page).to have_css('.stars')
  end
end

Then("I should see the price {string}") do |price|
  within('.result-modal') do
    expect(page).to have_content(price)
  end
end

Then("I should see the address {string}") do |address_part|
  within('.result-modal') do
    expect(page).to have_content(address_part)
  end
end

Then("I should see a {string} button") do |text|
  within('.result-modal') do
    expect(page).to have_content(text)
  end
end

Then("I should see text indicating a partial match like {string} or {string}") do |text1, text2|
  within('.result-modal') do
    expect(page.text).to match(/#{text1}|#{text2}/)
  end
end

# ==========================================
# HELPERS
# ==========================================

Given("the database has limited restaurants") do
  Restaurant.destroy_all
  Restaurant.create!(
    name: "Test Place",
    neighborhood: "SoHo",
    price: "$$",
    categories: ["American"], 
    rating: 4.5,
    address: "123 Test St",
    is_open_now: true,
    image_url: "https://example.com/image.jpg"
  )
end

Given("I have spun the wheel and see a result") do
  steps %{
    Given I am on the solo spin page
    When I fill in "Your Name" with "Test User"
    And I select "SoHo" from the "Neighborhood" dropdown
    And I select "$$" from the "Price Range" dropdown
    And I select "American" from the cuisine grid
    And I click "Spin the Wheel!"
    Then I should see the result modal
  }
end

When("I click the {string} button") do |text|
  within('.result-modal') do
    find('button', text: text).click
  end
end

Then("the share button text should change to {string}") do |text|
  within('.result-modal') do
    expect(page).to have_button(text)
  end
end