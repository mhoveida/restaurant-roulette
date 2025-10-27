# app/controllers/solo_spin_controller.rb
class SoloSpinController < ApplicationController
  def show
    @service = RestaurantService.new

    # Read optional filter parameters
    @location = params[:location]
    @price = params[:price]
    @categories = params[:categories]
    @name = current_user&.first_name || ""

    # If filters are provided (spinning the wheel), get a random restaurant
    if @location.present?
      # Parse categories - convert comma-separated string to array, or nil if blank
      categories_array = if @categories.present?
        @categories.split(",").map(&:strip).reject(&:empty?)
      else
        nil
      end

      @restaurant = @service.random_restaurant(
        location: @location,
        categories: categories_array,
        price: @price
      )
    end
  end
end
