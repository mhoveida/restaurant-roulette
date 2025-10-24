# app/controllers/solo_spin_controller.rb
class SoloSpinController < ApplicationController
  def show
    @service = RestaurantService.new

    # Read optional filter parameters
    @location = params[:location]
    @price = params[:price]
    @categories = params[:categories]
    @name = current_user&.name || ""

    # If filters are provided (spinning the wheel), get a random restaurant
    if @location.present?
      @restaurant = @service.random_restaurant(
        location: @location,
        categories: @categories,
        price: @price
      )
    end
  end
end
