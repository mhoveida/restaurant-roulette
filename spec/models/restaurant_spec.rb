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

    it "returns restaurants matching the cuisine" do
      expect(Restaurant.by_cuisine("Italian")).to include(italian_restaurant)
      expect(Restaurant.by_cuisine("Italian")).not_to include(mexican_restaurant)
    end

    it "returns all restaurants if cuisine is blank" do
      expect(Restaurant.by_cuisine("")).to include(italian_restaurant, mexican_restaurant)
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

  # --- METHOD TESTS --- (Example for has_cuisine?)

  describe "#has_cuisine?" do
    let(:restaurant) { FactoryBot.create(:restaurant, categories: [ "Italian", "Mediterranean" ]) }

    it "returns true if the restaurant has the specified cuisine (case-insensitive)" do
      expect(restaurant.has_cuisine?("italian")).to be true
      expect(restaurant.has_cuisine?("Mediterranean")).to be true
    end

    it "returns false if the restaurant does not have the specified cuisine" do
      expect(restaurant.has_cuisine?("Mexican")).to be false
    end

    it "returns false if categories is nil or not an array" do
      restaurant.update(categories: nil)
      expect(restaurant.has_cuisine?("Italian")).to be false
    end
  end
end
