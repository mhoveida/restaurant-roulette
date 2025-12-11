class SoloSpinController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :show, :spin ], raise: false
  def show
    @name = current_user&.first_name || ""
  end

  def spin
    location = params[:location]
    price = params[:price]
    categories = params[:categories] || []
    dietary_restrictions = params[:dietary_restrictions] || []

    result = find_random_restaurant(
      location: location,
      price: price,
      categories: categories,
      dietary_restrictions: dietary_restrictions
    )

    if result[:restaurant]
      render json: {
        success: true,
        restaurant: result[:restaurant].as_json,
        match_type: result[:match_type]
      }
    else
      render json: {
        success: false,
        error: "No restaurants found. Try different preferences!"
      }
    end
  end

  private

  def find_random_restaurant(location:, price:, categories:, dietary_restrictions:)
    # Try exact match first
    result = search_restaurants(
      location: location, 
      price: price, 
      categories: categories,
      dietary_restrictions: dietary_restrictions
    )
    return { restaurant: result, match_type: "exact" } if result

    # Fallback 1: Location + Price + Dietary
    result = search_restaurants(
      location: location, 
      price: price, 
      categories: [],
      dietary_restrictions: dietary_restrictions
    )
    return { restaurant: result, match_type: "location_price_dietary" } if result

    # Fallback 2: Location + Price
    result = search_restaurants(
      location: location, 
      price: price, 
      categories: [],
      dietary_restrictions: []
    )
    return { restaurant: result, match_type: "location_price" } if result

    # Fallback 3: Location + Cuisine + Dietary
    result = search_restaurants(
      location: location, 
      price: nil, 
      categories: categories,
      dietary_restrictions: dietary_restrictions
    )
    return { restaurant: result, match_type: "location_cuisine_dietary" } if result

    # Fallback 4: Location + Cuisine
    result = search_restaurants(
      location: location, 
      price: nil, 
      categories: categories,
      dietary_restrictions: []
    )
    return { restaurant: result, match_type: "location_cuisine" } if result

    # Fallback 5: Location + Dietary
    result = search_restaurants(
      location: location, 
      price: nil, 
      categories: [],
      dietary_restrictions: dietary_restrictions
    )
    return { restaurant: result, match_type: "location_dietary" } if result

    # Fallback 6: Location only
    result = search_restaurants(
      location: location, 
      price: nil, 
      categories: [],
      dietary_restrictions: []
    )
    return { restaurant: result, match_type: "location_only" } if result

    # Fallback 7: Price + Cuisine + Dietary
    result = search_restaurants(
      location: nil, 
      price: price, 
      categories: categories,
      dietary_restrictions: dietary_restrictions
    )
    return { restaurant: result, match_type: "price_cuisine_dietary" } if result

    # Fallback 8: Price + Cuisine
    result = search_restaurants(
      location: nil, 
      price: price, 
      categories: categories,
      dietary_restrictions: []
    )
    return { restaurant: result, match_type: "price_cuisine" } if result

    # Fallback 9: Cuisine + Dietary
    result = search_restaurants(
      location: nil, 
      price: nil, 
      categories: categories,
      dietary_restrictions: dietary_restrictions
    )
    return { restaurant: result, match_type: "cuisine_dietary" } if result

    # Fallback 10: Cuisine only
    result = search_restaurants(
      location: nil, 
      price: nil, 
      categories: categories,
      dietary_restrictions: []
    )
    return { restaurant: result, match_type: "cuisine_only" } if result

    # Fallback 11: Dietary only
    result = search_restaurants(
      location: nil, 
      price: nil, 
      categories: [],
      dietary_restrictions: dietary_restrictions
    )
    return { restaurant: result, match_type: "dietary_only" } if result

    # Fallback 12: Price only
    result = search_restaurants(
      location: nil, 
      price: price, 
      categories: [],
      dietary_restrictions: []
    )
    return { restaurant: result, match_type: "price_only" } if result

    # Last resort
    result = Restaurant.order("RANDOM()").first
    return { restaurant: result, match_type: "random" } if result

    { restaurant: nil, match_type: "none" }
  end

  def search_restaurants(location:, price:, categories:, dietary_restrictions:)
    query = Restaurant.all

    if location.present?
      query = query.where(
        "LOWER(neighborhood) LIKE LOWER(?) OR LOWER(address) LIKE LOWER(?)",
        "%#{location}%", "%#{location}%"
      )
    end

    query = query.where(price: price) if price.present?

    if categories.present? && categories.any?
      category_conditions = categories.map { |cat| "categories::text LIKE ?" }
      category_values = categories.map { |cat| "%#{cat}%" }

      query = query.where(category_conditions.join(" OR "), *category_values)
    end

    # NEW: Add dietary restrictions filtering
    if dietary_restrictions.present? && dietary_restrictions.any?
      # If "No Restriction" is selected, skip dietary filtering
      unless dietary_restrictions.include?("No Restriction")
        dietary_conditions = dietary_restrictions.map { "dietary_restrictions LIKE ?" }
        dietary_values = dietary_restrictions.map { |rest| "%#{rest}%" }
        query = query.where(dietary_conditions.join(" OR "), *dietary_values)
      end
    end

    # Use Arel.sql to avoid deprecation warnings and ensure compatibility
    query.order(Arel.sql("RANDOM()")).first
  end
end
