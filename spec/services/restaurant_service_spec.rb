# spec/services/restaurant_service_spec.rb

require 'rails_helper'

RSpec.describe RestaurantService, type: :service do
  let(:service) { described_class.new }

  # Create test restaurants with various attributes
  let!(:italian_cheap) do
    Restaurant.create!(
      name: "Joe's Pizza",
      rating: 4.5,
      price: "$",
      address: "123 Main St, New York, NY",
      phone: "+1 212-555-0001",
      image_url: "https://example.com/pizza.jpg",
      latitude: 40.7128,
      longitude: -74.0060,
      review_count: 100,
      is_open_now: true,
      closing_time: "10:00 PM",
      categories: [ "Pizza", "Italian", "Casual" ]
    )
  end

  let!(:italian_expensive) do
    Restaurant.create!(
      name: "Carbone",
      rating: 4.8,
      price: "$$$",
      address: "181 Thompson St, New York, NY",
      phone: "+1 212-555-0002",
      image_url: "https://example.com/carbone.jpg",
      latitude: 40.7265,
      longitude: -74.0033,
      review_count: 500,
      is_open_now: true,
      closing_time: "11:00 PM",
      categories: [ "Italian", "Fine Dining", "Wine Bar" ]
    )
  end

  let!(:japanese_moderate) do
    Restaurant.create!(
      name: "Sushi Place",
      rating: 4.6,
      price: "$$",
      address: "456 Oak St, New York, NY",
      phone: "+1 212-555-0003",
      image_url: "https://example.com/sushi.jpg",
      latitude: 40.7580,
      longitude: -73.9855,
      review_count: 200,
      is_open_now: true,
      closing_time: "9:00 PM",
      categories: [ "Japanese", "Sushi", "Seafood" ]
    )
  end

  let!(:mexican_cheap) do
    Restaurant.create!(
      name: "Taco Stand",
      rating: 4.2,
      price: "$",
      address: "789 Elm St, New York, NY",
      phone: "+1 212-555-0004",
      image_url: "https://example.com/tacos.jpg",
      latitude: 40.7489,
      longitude: -73.9680,
      review_count: 150,
      is_open_now: false,
      closing_time: "8:00 PM",
      categories: [ "Mexican", "Tacos", "Casual" ]
    )
  end

  let!(:chinese_moderate) do
    Restaurant.create!(
      name: "Dim Sum Palace",
      rating: 4.4,
      price: "$$",
      address: "321 Pine St, New York, NY",
      phone: "+1 212-555-0005",
      image_url: "https://example.com/dimsum.jpg",
      latitude: 40.7200,
      longitude: -73.9900,
      review_count: 300,
      is_open_now: true,
      closing_time: "10:30 PM",
      categories: [ "Chinese", "Dim Sum", "Cantonese" ]
    )
  end

  describe '#search_restaurants' do
    context 'with no filters' do
      it 'returns all restaurants' do
        results = service.search_restaurants(location: "New York")
        expect(results.count).to eq(5)
      end

      it 'returns restaurants as hashes' do
        results = service.search_restaurants(location: "New York")
        expect(results.first).to be_a(Hash)
        expect(results.first).to have_key("name")
        expect(results.first).to have_key("rating")
        expect(results.first).to have_key("price")
      end
    end

    context 'with location filter' do
      it 'filters by location when provided' do
        results = service.search_restaurants(location: "New York")
        expect(results.count).to eq(5)
      end

      it 'returns all restaurants when location is blank' do
        results = service.search_restaurants(location: "")
        expect(results.count).to eq(5)
      end

      it 'returns all restaurants when location is nil' do
        results = service.search_restaurants(location: nil)
        expect(results.count).to eq(5)
      end
    end

    context 'with price filter' do
      it 'filters by price when provided' do
        results = service.search_restaurants(location: "New York", price: "$")
        expect(results.count).to eq(2)
        expect(results.map { |r| r["name"] }).to contain_exactly("Joe's Pizza", "Taco Stand")
      end

      it 'filters by moderate price' do
        results = service.search_restaurants(location: "New York", price: "$$")
        expect(results.count).to eq(2)
        expect(results.map { |r| r["name"] }).to contain_exactly("Sushi Place", "Dim Sum Palace")
      end

      it 'filters by expensive price' do
        results = service.search_restaurants(location: "New York", price: "$$$")
        expect(results.count).to eq(1)
        expect(results.first["name"]).to eq("Carbone")
      end

      it 'returns empty array when no matches' do
        results = service.search_restaurants(location: "New York", price: "$$$$")
        expect(results).to be_empty
      end

      it 'returns all restaurants when price is nil' do
        results = service.search_restaurants(location: "New York", price: nil)
        expect(results.count).to eq(5)
      end
    end

    context 'with categories filter' do
      it 'filters by single category as array' do
        results = service.search_restaurants(location: "New York", categories: [ "Italian" ])
        expect(results.count).to eq(2)
        expect(results.map { |r| r["name"] }).to contain_exactly("Joe's Pizza", "Carbone")
      end

      it 'filters by single category as string' do
        results = service.search_restaurants(location: "New York", categories: "Japanese")
        expect(results.count).to eq(1)
        expect(results.first["name"]).to eq("Sushi Place")
      end

      it 'filters by multiple categories as array' do
        results = service.search_restaurants(location: "New York", categories: [ "Italian", "Japanese" ])
        expect(results.count).to eq(3)
        expect(results.map { |r| r["name"] }).to contain_exactly("Joe's Pizza", "Carbone", "Sushi Place")
      end

      it 'filters by multiple categories as comma-separated string' do
        results = service.search_restaurants(location: "New York", categories: "Mexican, Chinese")
        expect(results.count).to eq(2)
        expect(results.map { |r| r["name"] }).to contain_exactly("Taco Stand", "Dim Sum Palace")
      end

      it 'matches categories exactly as stored' do
        # Categories are stored with capital letters in test data
        results = service.search_restaurants(location: "New York", categories: [ "Italian" ])
        expect(results.count).to eq(2)
        expect(results.map { |r| r["name"] }).to contain_exactly("Joe's Pizza", "Carbone")
      end

      it 'handles categories with extra spaces' do
        results = service.search_restaurants(location: "New York", categories: "  Italian  ,  Japanese  ")
        expect(results.count).to eq(3)
      end

      it 'returns all restaurants when categories is nil' do
        results = service.search_restaurants(location: "New York", categories: nil)
        expect(results.count).to eq(5)
      end

      it 'returns all restaurants when categories is empty array' do
        results = service.search_restaurants(location: "New York", categories: [])
        expect(results.count).to eq(5)
      end

      it 'returns empty array when no category matches' do
        results = service.search_restaurants(location: "New York", categories: [ "French" ])
        expect(results).to be_empty
      end
    end

    context 'with combined filters' do
      it 'filters by price and categories' do
        results = service.search_restaurants(
          location: "New York",
          price: "$",
          categories: [ "Italian" ]
        )
        expect(results.count).to eq(1)
        expect(results.first["name"]).to eq("Joe's Pizza")
      end

      it 'filters by location, price, and categories' do
        results = service.search_restaurants(
          location: "New York",
          price: "$$",
          categories: [ "Japanese" ]
        )
        expect(results.count).to eq(1)
        expect(results.first["name"]).to eq("Sushi Place")
      end

      it 'returns empty array when combined filters match nothing' do
        results = service.search_restaurants(
          location: "New York",
          price: "$$$",
          categories: [ "Mexican" ]
        )
        expect(results).to be_empty
      end
    end

    context 'hash structure' do
      it 'includes all required fields' do
        results = service.search_restaurants(location: "New York")
        result = results.first

        expect(result).to have_key("id")
        expect(result).to have_key("name")
        expect(result).to have_key("rating")
        expect(result).to have_key("price")
        expect(result).to have_key("address")
        expect(result).to have_key("phone")
        expect(result).to have_key("image_url")
        expect(result).to have_key("latitude")
        expect(result).to have_key("longitude")
        expect(result).to have_key("review_count")
        expect(result).to have_key("is_open_now")
        expect(result).to have_key("closing_time")
        expect(result).to have_key("categories")
      end

      it 'converts values to correct types' do
        results = service.search_restaurants(location: "New York")
        result = results.first

        expect(result["id"]).to be_a(String)
        expect(result["rating"]).to be_a(Float)
        expect(result["latitude"]).to be_a(Float)
        expect(result["longitude"]).to be_a(Float)
        expect(result["review_count"]).to be_a(Integer)
        expect(result["is_open_now"]).to be_in([ true, false ])
        expect(result["categories"]).to be_an(Array)
      end
    end
  end

  describe '#random_restaurant' do
    it 'returns a single restaurant' do
      result = service.random_restaurant(location: "New York")
      expect(result).to be_a(Hash)
      expect(result).to have_key("name")
    end

    it 'returns a restaurant matching the filters' do
      result = service.random_restaurant(
        location: "New York",
        price: "$",
        categories: [ "Italian" ]
      )
      expect(result["name"]).to eq("Joe's Pizza")
    end

    it 'returns nil when no restaurants match' do
      result = service.random_restaurant(
        location: "New York",
        price: "$$$$",
        categories: [ "French" ]
      )
      expect(result).to be_nil
    end

    it 'respects price filter' do
      result = service.random_restaurant(location: "New York", price: "$$$")
      expect(result["name"]).to eq("Carbone")
    end

    it 'respects categories filter' do
      result = service.random_restaurant(location: "New York", categories: [ "Japanese" ])
      expect(result["name"]).to eq("Sushi Place")
    end

    context 'randomness' do
      it 'can return different restaurants on multiple calls' do
        # This test checks that the method is capable of returning different results
        # We'll call it many times and check if we get at least 2 different restaurants
        results = 50.times.map { service.random_restaurant(location: "New York") }
        unique_names = results.map { |r| r["name"] }.uniq
        expect(unique_names.count).to be > 1
      end
    end

    it 'works with no filters except location' do
      result = service.random_restaurant(location: "New York")
      expect(result).to be_a(Hash)
      expect([ "Joe's Pizza", "Carbone", "Sushi Place", "Taco Stand", "Dim Sum Palace" ]).to include(result["name"])
    end
  end

  describe '#get_unique_restaurants' do
    context 'basic functionality' do
      it 'returns requested number of restaurants' do
        results = service.get_unique_restaurants(location: "New York", count: 3)
        expect(results.count).to eq(3)
      end

      it 'returns fewer restaurants if not enough available' do
        results = service.get_unique_restaurants(location: "New York", count: 10)
        expect(results.count).to eq(5) # Only 5 restaurants in total
      end

      it 'returns empty array when count is 0' do
        results = service.get_unique_restaurants(location: "New York", count: 0)
        expect(results).to be_empty
      end

      it 'returns restaurants as hashes' do
        results = service.get_unique_restaurants(location: "New York", count: 2)
        expect(results.first).to be_a(Hash)
        expect(results.first).to have_key("name")
      end
    end

    context 'with filters' do
      it 'respects price filter' do
        results = service.get_unique_restaurants(
          location: "New York",
          price: "$",
          count: 5
        )
        expect(results.count).to eq(2)
        expect(results.map { |r| r["price"] }.uniq).to eq([ "$" ])
      end

      it 'respects categories filter' do
        results = service.get_unique_restaurants(
          location: "New York",
          categories: [ "Italian" ],
          count: 5
        )
        expect(results.count).to eq(2)
        restaurant_names = results.map { |r| r["name"] }
        expect(restaurant_names).to contain_exactly("Joe's Pizza", "Carbone")
      end

      it 'respects combined filters' do
        results = service.get_unique_restaurants(
          location: "New York",
          price: "$",
          categories: [ "Italian" ],
          count: 5
        )
        expect(results.count).to eq(1)
        expect(results.first["name"]).to eq("Joe's Pizza")
      end
    end

    context 'with exclusions' do
      it 'excludes restaurants by ID' do
        exclude_ids = [ italian_cheap.id, japanese_moderate.id ]
        results = service.get_unique_restaurants(
          location: "New York",
          count: 5,
          exclude_ids: exclude_ids
        )

        expect(results.count).to eq(3)
        restaurant_names = results.map { |r| r["name"] }
        expect(restaurant_names).not_to include("Joe's Pizza")
        expect(restaurant_names).not_to include("Sushi Place")
      end

      it 'works with empty exclusion array' do
        results = service.get_unique_restaurants(
          location: "New York",
          count: 3,
          exclude_ids: []
        )
        expect(results.count).to eq(3)
      end

      it 'excludes all restaurants if all IDs are excluded' do
        all_ids = [ italian_cheap.id, italian_expensive.id, japanese_moderate.id,
                   mexican_cheap.id, chinese_moderate.id ]
        results = service.get_unique_restaurants(
          location: "New York",
          count: 5,
          exclude_ids: all_ids
        )
        expect(results).to be_empty
      end

      it 'combines exclusions with other filters' do
        results = service.get_unique_restaurants(
          location: "New York",
          price: "$",
          count: 5,
          exclude_ids: [ italian_cheap.id ]
        )
        expect(results.count).to eq(1)
        expect(results.first["name"]).to eq("Taco Stand")
      end
    end

    context 'uniqueness' do
      it 'returns unique restaurants (no duplicates)' do
        results = service.get_unique_restaurants(location: "New York", count: 3)
        names = results.map { |r| r["name"] }
        expect(names.uniq.count).to eq(names.count)
      end
    end

    context 'randomness' do
      it 'returns different sets on multiple calls' do
        # Call multiple times and check that we get different combinations
        sets = 10.times.map do
          service.get_unique_restaurants(location: "New York", count: 3)
                 .map { |r| r["name"] }
                 .sort
        end

        unique_sets = sets.uniq
        # We should get at least 2 different sets out of 10 calls
        expect(unique_sets.count).to be > 1
      end
    end

    context 'edge cases' do
      it 'handles nil location' do
        results = service.get_unique_restaurants(location: nil, count: 3)
        expect(results.count).to eq(3)
      end

      it 'handles nil categories' do
        results = service.get_unique_restaurants(
          location: "New York",
          categories: nil,
          count: 3
        )
        expect(results.count).to eq(3)
      end

      it 'handles nil price' do
        results = service.get_unique_restaurants(
          location: "New York",
          price: nil,
          count: 3
        )
        expect(results.count).to eq(3)
      end
    end
  end

  describe '#all_restaurants' do
    it 'returns all restaurants' do
      results = service.all_restaurants
      expect(results.count).to eq(5)
    end

    it 'returns restaurants as hashes' do
      results = service.all_restaurants
      expect(results.first).to be_a(Hash)
      expect(results.first).to have_key("name")
    end

    it 'includes all restaurant names' do
      results = service.all_restaurants
      names = results.map { |r| r["name"] }
      expect(names).to contain_exactly(
        "Joe's Pizza",
        "Carbone",
        "Sushi Place",
        "Taco Stand",
        "Dim Sum Palace"
      )
    end

    it 'returns empty array when no restaurants exist' do
      Restaurant.destroy_all
      results = service.all_restaurants
      expect(results).to be_empty
    end

    it 'each restaurant has correct hash structure' do
      results = service.all_restaurants
      results.each do |restaurant|
        expect(restaurant).to have_key("id")
        expect(restaurant).to have_key("name")
        expect(restaurant).to have_key("rating")
        expect(restaurant).to have_key("price")
        expect(restaurant).to have_key("address")
        expect(restaurant).to have_key("categories")
      end
    end
  end

  describe 'integration scenarios' do
    context 'realistic user flows' do
      it 'solo spin with preferences' do
        # User wants cheap Italian food
        result = service.random_restaurant(
          location: "New York",
          price: "$",
          categories: [ "Italian" ]
        )

        expect(result).not_to be_nil
        expect(result["name"]).to eq("Joe's Pizza")
        expect(result["price"]).to eq("$")
      end

      it 'group room getting multiple unique restaurants' do
        # First spin
        first_batch = service.get_unique_restaurants(
          location: "New York",
          count: 2
        )
        first_ids = first_batch.map { |r| r["id"] }

        # Second spin excluding first results
        second_batch = service.get_unique_restaurants(
          location: "New York",
          count: 2,
          exclude_ids: first_ids
        )
        second_ids = second_batch.map { |r| r["id"] }

        # No overlap
        expect(first_ids & second_ids).to be_empty
      end

      it 'searching with multiple cuisines' do
        # User likes both Italian and Japanese
        results = service.search_restaurants(
          location: "New York",
          categories: [ "Italian", "Japanese" ]
        )

        expect(results.count).to eq(3)
        names = results.map { |r| r["name"] }
        expect(names).to include("Joe's Pizza", "Carbone", "Sushi Place")
      end
    end

    context 'empty result scenarios' do
      it 'handles no matches gracefully in random_restaurant' do
        result = service.random_restaurant(
          location: "New York",
          price: "$$$$",
          categories: [ "French", "Moroccan" ]
        )
        expect(result).to be_nil
      end

      it 'handles no matches gracefully in search_restaurants' do
        results = service.search_restaurants(
          location: "New York",
          price: "$$$$",
          categories: [ "Thai" ]
        )
        expect(results).to be_empty
      end

      it 'handles no matches gracefully in get_unique_restaurants' do
        results = service.get_unique_restaurants(
          location: "New York",
          price: "$$$$",
          count: 5
        )
        expect(results).to be_empty
      end
    end
  end

  describe 'private method #restaurant_to_hash' do
    it 'converts restaurant model to proper hash format' do
      results = service.search_restaurants(location: "New York", price: "$")
      result = results.first

      # Verify the conversion works correctly
      expect(result["id"]).to be_a(String)
      expect(result["name"]).to be_a(String)
      expect(result["rating"]).to be_a(Float)
      expect(result["price"]).to match(/^\$+$/)
      expect(result["categories"]).to be_an(Array)
    end

    it 'handles nil values for optional fields' do
      restaurant_without_coords = Restaurant.create!(
        name: "No Coords Place",
        rating: 4.0,
        price: "$$",
        address: "Somewhere",
        phone: "+1 212-555-9999",
        image_url: "https://example.com/img.jpg",
        latitude: nil,
        longitude: nil,
        review_count: 0,
        is_open_now: true,
        closing_time: "9:00 PM",
        categories: [ "Other" ]
      )

      results = service.search_restaurants(location: "New York")
      result = results.find { |r| r["name"] == "No Coords Place" }

      expect(result).not_to be_nil
      expect(result["latitude"]).to be_nil
      expect(result["longitude"]).to be_nil
    end
  end
end
