require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  # Use FactoryBot to create a valid restaurant hash
  let(:valid_attributes) { FactoryBot.attributes_for(:restaurant) }

  # --- VALIDATION TESTS ---

  it "is valid with valid attributes" do
    restaurant = Restaurant.new(valid_attributes)
    expect(restaurant).to be_valid
  end

  it "is not valid without a name" do
    restaurant = Restaurant.new(valid_attributes.except(:name))
    expect(restaurant).not_to be_valid
  end

  it "is not valid without a rating" do
    restaurant = Restaurant.new(valid_attributes.except(:rating))
    expect(restaurant).not_to be_valid
  end

  it "is not valid with a rating less than 0" do
    restaurant = Restaurant.new(valid_attributes.merge(rating: -1))
    expect(restaurant).not_to be_valid
  end

  it "is not valid with a rating greater than 5" do
    restaurant = Restaurant.new(valid_attributes.merge(rating: 5.1))
    expect(restaurant).not_to be_valid
  end

  it "is not valid without a price" do
    restaurant = Restaurant.new(valid_attributes.except(:price))
    expect(restaurant).not_to be_valid
  end

  it "is not valid with an invalid price symbol" do
    restaurant = Restaurant.new(valid_attributes.merge(price: "€€"))
    expect(restaurant).not_to be_valid
  end

  it "is valid with allowed price symbols" do
    [ "$", "$$", "$$$", "$$$$" ].each do |price|
      restaurant = Restaurant.new(valid_attributes.merge(price: price))
      expect(restaurant).to be_valid
    end
  end

  it "is not valid without an address" do
    restaurant = Restaurant.new(valid_attributes.except(:address))
    expect(restaurant).not_to be_valid
  end

  # --- SCOPE TESTS ---

  describe ".by_cuisine" do
    let!(:italian_restaurant) { FactoryBot.create(:restaurant, categories: [ "Italian", "Pasta" ]) }
    let!(:mexican_restaurant) { FactoryBot.create(:restaurant, categories: [ "Mexican", "Tacos" ]) }

    # FIXED: Added .to_a and .count to force SQL execution (covers line 14)
    it "returns restaurants matching the cuisine" do
      results = Restaurant.by_cuisine("Italian")
      # Force SQL execution to ensure WHERE clause runs
      expect(results.to_a).to include(italian_restaurant)
      expect(results.to_a).not_to include(mexican_restaurant)
      expect(results.count).to eq(1)
      # Additional verification to ensure WHERE executed
      expect(results.pluck(:id)).to include(italian_restaurant.id)
      expect(results.pluck(:id)).not_to include(mexican_restaurant.id)
    end

    it "returns all restaurants if cuisine is blank" do
      results = Restaurant.by_cuisine("")
      expect(results.to_a).to include(italian_restaurant, mexican_restaurant)
      expect(results.count).to eq(2)
    end

    it "returns all restaurants if cuisine is nil" do
      results = Restaurant.by_cuisine(nil)
      expect(results.to_a).to include(italian_restaurant, mexican_restaurant)
    end
  end

  describe ".by_price" do
    let!(:cheap_restaurant) { FactoryBot.create(:restaurant, price: "$") }
    let!(:expensive_restaurant) { FactoryBot.create(:restaurant, price: "$$$") }

    it "returns restaurants matching the price" do
      expect(Restaurant.by_price("$")).to include(cheap_restaurant)
      expect(Restaurant.by_price("$")).not_to include(expensive_restaurant)
    end

    it "returns all restaurants if price is blank" do
      expect(Restaurant.by_price("")).to include(cheap_restaurant, expensive_restaurant)
    end
  end

  describe ".open_now" do
    let!(:open_restaurant) { FactoryBot.create(:restaurant, is_open_now: true) }
    let!(:closed_restaurant) { FactoryBot.create(:restaurant, is_open_now: false) }

    it "returns only restaurants that are open" do
      expect(Restaurant.open_now).to include(open_restaurant)
      expect(Restaurant.open_now).not_to include(closed_restaurant)
    end
  end

  # --- METHOD TESTS ---

  describe "#cuisine_list" do
    # FIXED: Changed build to create to ensure serialization works (covers line 25)
    it "returns a comma-separated string of categories" do
      restaurant = FactoryBot.create(:restaurant, categories: [ "Italian", "Pasta", "Pizza" ])
      restaurant.reload  # Ensure DB round-trip
      result = restaurant.cuisine_list
      expect(result).to eq("Italian, Pasta, Pizza")
      expect(restaurant.categories).to be_a(Array)
    end

    it "returns an empty string if categories is empty" do
      restaurant = FactoryBot.create(:restaurant, categories: [])
      restaurant.reload
      expect(restaurant.cuisine_list).to eq("")
    end

    it "returns an empty string if categories is nil" do
      restaurant = FactoryBot.create(:restaurant, categories: nil)
      restaurant.reload
      result = restaurant.cuisine_list
      expect(result).to eq("")
      expect(restaurant.categories).to be_nil
    end

    # NEW: Added test for FALSE branch of ternary operator (covers line 26)
    it "returns empty string when categories is not an array" do
      restaurant = Restaurant.new(
        name: "Not Array Test",
        rating: 4.0,
        price: "$$",
        address: "123 Test St",
        categories: "this is a string, not an array"
      )
      result = restaurant.cuisine_list
      expect(result).to eq("")
      expect(restaurant.categories.is_a?(Array)).to be false
    end
  end

  describe "#has_cuisine?" do
    let(:restaurant) { FactoryBot.create(:restaurant, categories: [ "Italian", "Mediterranean" ]) }

    it "returns true if the restaurant has the specified cuisine (case-insensitive)" do
      expect(restaurant.has_cuisine?("italian")).to be true
      expect(restaurant.has_cuisine?("Mediterranean")).to be true
      expect(restaurant.has_cuisine?("ITALIAN")).to be true
    end

    it "returns false if the restaurant does not have the specified cuisine" do
      expect(restaurant.has_cuisine?("Mexican")).to be false
    end

    # CRITICAL: This covers line 29 (return false unless categories.is_a?(Array))
    it "returns false if categories is nil" do
      restaurant.update(categories: nil)
      restaurant.reload
      result = restaurant.has_cuisine?("Italian")
      expect(result).to be false
      expect(restaurant.categories).to be_nil
    end

    # CRITICAL: This covers line 30 (categories.any? with downcase.include?)
    it "uses case-insensitive partial matching" do
      expect(restaurant.has_cuisine?("ital")).to be true
      expect(restaurant.has_cuisine?("MEDITERR")).to be true
      expect(restaurant.has_cuisine?("mex")).to be false
    end

    it "returns false for non-array categories" do
      restaurant = Restaurant.new(
        name: "Test",
        rating: 4.0,
        price: "$$",
        address: "123 Test",
        categories: "Italian"
      )
      expect(restaurant.has_cuisine?("Italian")).to be false
    end
  end
end
