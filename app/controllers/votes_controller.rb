class VotesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    room = Room.find(params[:room_id])
    vote = room.votes.find_or_initialize_by(
      restaurant_id: vote_params[:restaurant_id],
      voter_name: vote_params[:voter_name]
    )
    vote.value = vote_params[:value]

    if vote.save
      # ✅ After saving, compute updated counts
      counts = room.votes.group(:restaurant_id, :value).count
      # Example: { [1, "up"] => 3, [1, "down"] => 1, [2, "up"] => 2 }

      # ✅ Broadcast to everyone in this room
      ActionCable.server.broadcast("room_#{room.id}", {
        type: "vote_update",
        counts: counts
      })

      render json: { success: true, message: "Vote recorded", vote: vote }
    else
      render json: { success: false, errors: vote.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def vote_params
    params.require(:vote).permit(:restaurant_id, :voter_name, :value)
  end
end
