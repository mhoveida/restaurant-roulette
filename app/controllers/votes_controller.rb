class VotesController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    room = Room.find(params[:room_id])
    vote = room.votes.new(vote_params)

    if vote.save
      render json: { success: true, vote: vote }, status: :created
    else
      render json: { success: false, errors: vote.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def vote_params
    params.require(:vote).permit(:restaurant_id, :voter_name, :value)
  end
end
