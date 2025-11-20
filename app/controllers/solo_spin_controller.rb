class SoloSpinController < ApplicationController
  def show
    @name = current_user&.first_name || ""
  end

  def spin
    location = params[:location]
    price = params[:price]
    categories = params[:categories] || []
    
    result = find_random_restaurant(
      location: location,
      price: price,
      categories: categories
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

  def find_random_restaurant(location:, price:, categories:)
    result = search_restaurants(location: location, price: price, categories: categories)
    return { restaurant: result, match_type: "exact" } if result
    
    result = search_restaurants(location: location, price: price, categories: [])
    return { restaurant: result, match_type: "location_price" } if result
    
    result = search_restaurants(location: location, price: nil, categories: categories)
    return { restaurant: result, match_type: "location_cuisine" } if result
    
    result = search_restaurants(location: location, price: nil, categories: [])
    return { restaurant: result, match_type: "location_only" } if result
    
    result = search_restaurants(location: nil, price: price, categories: categories)
    return { restaurant: result, match_type: "price_cuisine" } if result
    
    result = search_restaurants(location: nil, price: nil, categories: categories)
    return { restaurant: result, match_type: "cuisine_only" } if result
    
    result = search_restaurants(location: nil, price: price, categories: [])
    return { restaurant: result, match_type: "price_only" } if result
    
    result = Restaurant.order("RANDOM()").first
    return { restaurant: result, match_type: "random" } if result
    
    { restaurant: nil, match_type: "none" }
  end

  def search_restaurants(location:, price:, categories:)
    query = Restaurant.all
    
    if location.present?
      query = query.where(
        "LOWER(neighborhood) LIKE LOWER(?) OR LOWER(address) LIKE LOWER(?)",
        "%#{location}%", "%#{location}%"
      )
    end
    
    query = query.where(price: price) if price.present?
    
    if categories.present? && categories.any?
      category_conditions = categories.map { |cat| "categories LIKE ?" }
      category_values = categories.map { |cat| "%#{cat}%" }
      query = query.where(category_conditions.join(" OR "), *category_values)
    end
    
    query.order("RANDOM()").first
  end
end