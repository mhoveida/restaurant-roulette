class UserHistoriesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @histories = @user.user_restaurant_histories.recent.includes(:restaurant)
    @restaurants = @histories.map(&:restaurant)
  end

  def destroy
    @user = current_user
    history = @user.user_restaurant_histories.find_by(restaurant_id: params[:restaurant_id])

    if history
      history.destroy
      render json: { success: true, message: "Restaurant removed from history" }
    else
      render json: { success: false, error: "Restaurant not found" }, status: :not_found
    end
  end
end
