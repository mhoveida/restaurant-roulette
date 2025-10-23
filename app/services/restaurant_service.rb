# app/services/restaurant_service.rb

class RestaurantService
  # Search restaurants by criteria
  def search_restaurants(location:, categories: nil, price: nil)
    results = Restaurant.all

    # Filter by location (all are in NYC for now)
    results = results.by_location(location) if location.present?

    # Filter by cuisine/categories
    if categories.present?
      cuisine_array = categories.is_a?(Array) ? categories : categories.split(",").map(&:strip)
      # Search for first cuisine in the array
      cuisine = cuisine_array.first
      results = results.where("categories LIKE ?", "%#{cuisine}%")
    end

    # Filter by price
    results = results.by_price(price) if price.present?

    # Return as array of hashes (to match old YAML interface)
    results.map { |r| restaurant_to_hash(r) }
  end

  # Get one random restaurant
  def random_restaurant(location:, categories: nil, price: nil)
    results = search_restaurants(
      location: location,
      categories: categories,
      price: price
    )

    results.sample
  end

  # Get unique restaurants (for group rooms)
  def get_unique_restaurants(location:, categories: nil, price: nil, count: 3, exclude_ids: [])
    results = Restaurant.all

    # Apply filters
    results = results.by_location(location) if location.present?

    if categories.present?
      cuisine_array = categories.is_a?(Array) ? categories : categories.split(",").map(&:strip)
      cuisine = cuisine_array.first
      results = results.where("categories LIKE ?", "%#{cuisine}%")
    end

    results = results.by_price(price) if price.present?

    # Exclude already used restaurants
    results = results.where.not(id: exclude_ids) if exclude_ids.any?

    # Get random sample
    selected = results.order("RANDOM()").limit(count)

    selected.map { |r| restaurant_to_hash(r) }
  end

  # Get all restaurants
  def all_restaurants
    Restaurant.all.map { |r| restaurant_to_hash(r) }
  end

  private

  # Convert ActiveRecord model to hash (to match old YAML format)
  def restaurant_to_hash(restaurant)
    {
      "id" => restaurant.id.to_s,
      "name" => restaurant.name,
      "rating" => restaurant.rating.to_f,
      "price" => restaurant.price,
      "address" => restaurant.address,
      "phone" => restaurant.phone,
      "image_url" => restaurant.image_url,
      "latitude" => restaurant.latitude&.to_f,
      "longitude" => restaurant.longitude&.to_f,
      "review_count" => restaurant.review_count,
      "is_open_now" => restaurant.is_open_now,
      "closing_time" => restaurant.closing_time,
      "categories" => restaurant.categories
    }
  end
end
