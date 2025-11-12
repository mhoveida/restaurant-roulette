Given('the restaurant database has test data') do
  # Seed is already loaded from env.rb, but ensure we have data
  expect(Restaurant.count).to be > 0
end


Given(/^a restaurant with categories: (.+)$/) do |categories_json|
  categories = JSON.parse(categories_json)
  @test_restaurant = Restaurant.create!(
    name: "Test Restaurant #{rand(10000)}",
    rating: 4.5,
    price: "$$",
    address: "123 Test St, New York, NY 10001",
    categories: categories
  )
end

Given('a restaurant with empty categories array') do
  @test_restaurant = Restaurant.create!(
    name: "Empty Categories Restaurant",
    rating: 4.0,
    price: "$$",
    address: "456 Empty St, New York, NY 10002",
    categories: []
  )
end

Given('a restaurant with invalid categories type') do
  @test_restaurant = Restaurant.create!(
    name: "Invalid Categories Restaurant",
    rating: 4.0,
    price: "$$",
    address: "789 Invalid St, New York, NY 10003",
    categories: []
  )
  # Manually set categories to a non-array type, bypassing serialization
  @test_restaurant.update_column(:categories, "not_an_array")
  @test_restaurant.reload
end


Given('there are {int} open restaurants and {int} closed restaurants') do |open_count, closed_count|
  # Clear existing restaurants to have a clean slate
  Restaurant.delete_all
  
  # Create open restaurants
  open_count.times do |i|
    Restaurant.create!(
      name: "Open Restaurant #{i}",
      rating: 4.0,
      price: "$$",
      address: "#{i} Open St, New York, NY 10001",
      categories: ["American"],
      is_open_now: true
    )
  end

  # Create closed restaurants
  closed_count.times do |i|
    Restaurant.create!(
      name: "Closed Restaurant #{i}",
      rating: 4.0,
      price: "$$",
      address: "#{i} Closed St, New York, NY 10002",
      categories: ["American"],
      is_open_now: false
    )
  end
end

Given('all restaurants are closed') do
  Restaurant.update_all(is_open_now: false)
end


When('I request the cuisine list') do
  @cuisine_list_result = @test_restaurant.cuisine_list
end


When('I check if the restaurant has cuisine {string}') do |cuisine|
  @has_cuisine_result = @test_restaurant.has_cuisine?(cuisine)
end


When('I query for open restaurants only') do
  @open_restaurants = Restaurant.open_now
end


When('I create a restaurant with valid attributes') do
  @test_restaurant = Restaurant.new(
    name: "Valid Restaurant",
    rating: 4.5,
    price: "$$",
    address: "100 Valid St, New York, NY 10001",
    categories: ["Italian"]
  )
  @save_result = @test_restaurant.save
end

When('I create a restaurant without a name') do
  @test_restaurant = Restaurant.new(
    rating: 4.5,
    price: "$$",
    address: "200 No Name St, New York, NY 10001",
    categories: ["Italian"]
  )
  @save_result = @test_restaurant.save
end

When('I create a restaurant without a rating') do
  @test_restaurant = Restaurant.new(
    name: "No Rating Restaurant",
    price: "$$",
    address: "300 No Rating St, New York, NY 10001",
    categories: ["Italian"]
  )
  @save_result = @test_restaurant.save
end

When('I create a restaurant with rating {string}') do |rating|
  @test_restaurant = Restaurant.new(
    name: "Bad Rating Restaurant",
    rating: rating.to_f,
    price: "$$",
    address: "400 Bad Rating St, New York, NY 10001",
    categories: ["Italian"]
  )
  @save_result = @test_restaurant.save
end

When('I create a restaurant without a price') do
  @test_restaurant = Restaurant.new(
    name: "No Price Restaurant",
    rating: 4.5,
    address: "500 No Price St, New York, NY 10001",
    categories: ["Italian"]
  )
  @save_result = @test_restaurant.save
end

When('I create a restaurant with price {string}') do |price|
  @test_restaurant = Restaurant.new(
    name: "Bad Price Restaurant",
    rating: 4.5,
    price: price,
    address: "600 Bad Price St, New York, NY 10001",
    categories: ["Italian"]
  )
  @save_result = @test_restaurant.save
end

When(/^I create restaurants with prices (.+)$/) do |prices_string|
  @created_restaurants = []
  # Remove quotes and split by comma
  prices = prices_string.gsub('"', '').split(', ')
  
  prices.each_with_index do |price, i|
    restaurant = Restaurant.new(
      name: "Restaurant #{i}",
      rating: 4.0,
      price: price,
      address: "#{700 + i} Price Test St, New York, NY 10001",
      categories: ["American"]
    )
    @created_restaurants << restaurant if restaurant.save
  end
end

When('I create a restaurant without an address') do
  @test_restaurant = Restaurant.new(
    name: "No Address Restaurant",
    rating: 4.5,
    price: "$$",
    categories: ["Italian"]
  )
  @save_result = @test_restaurant.save
end


When('I search by cuisine with empty string') do
  @search_results = Restaurant.by_cuisine("")
end

When('I search by cuisine with nil value') do
  @search_results = Restaurant.by_cuisine(nil)
end

When('I search by price with empty string') do
  @search_results = Restaurant.by_price("")
end

When('I search by price with nil value') do
  @search_results = Restaurant.by_price(nil)
end


Then('the cuisine list should be {string}') do |expected_string|
  expect(@cuisine_list_result).to eq(expected_string)
end

Then('the cuisine list should be empty') do
  expect(@cuisine_list_result).to eq("")
end


Then('the has_cuisine result should be true') do
  expect(@has_cuisine_result).to be true
end

Then('the has_cuisine result should be false') do
  expect(@has_cuisine_result).to be false
end


Then('the open_now scope should return exactly {int} restaurants') do |count|
  expect(@open_restaurants.count).to eq(count)
end

Then('all returned restaurants should have is_open_now as true') do
  @open_restaurants.each do |restaurant|
    expect(restaurant.is_open_now).to be true
  end
end

Then('the open_now scope should return {int} restaurants') do |count|
  expect(@open_restaurants.count).to eq(count)
end


Then('the restaurant should be saved successfully') do
  expect(@save_result).to be true
  expect(@test_restaurant.persisted?).to be true
end

Then('the restaurant should not be saved') do
  expect(@save_result).to be false
  expect(@test_restaurant.persisted?).to be false
end

Then('I should see error {string}') do |error_message|
  expect(@test_restaurant.errors.full_messages).to include(error_message)
end

Then('all restaurants should be saved successfully') do
  expect(@created_restaurants.count).to eq(4)
  @created_restaurants.each do |restaurant|
    expect(restaurant.persisted?).to be true
  end
end


Then('the scope should return all restaurants') do
  expect(@search_results.count).to eq(Restaurant.count)
end