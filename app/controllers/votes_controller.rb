class VotesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @room = Room.find(params[:room_id])

    @vote = @room.votes.find_or_initialize_by(
      restaurant_id: vote_params[:restaurant_id],
      voter_name: vote_params[:voter_name]
    )
    @vote.value = vote_params[:value]

    if @vote.save
      # Safely build counts hash (avoid nils)
      counts = @room.votes.group(:restaurant_id, :value).count
      formatted_counts = counts.transform_keys do |(rid, val)|
        "#{rid},#{val}"
      end

      ActionCable.server.broadcast(
        "room_#{@room.id}",
        { type: "vote_update", counts: formatted_counts }
      )

      render json: { success: true, vote: @vote, counts: formatted_counts }
    else
      render json: { success: false, errors: @vote.errors.full_messages },
             status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Vote creation failed: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.take(5)
    render json: { success: false, errors: ["Internal server error: #{e.message}"] },
           status: :internal_server_error
  end

  private

  def vote_params
    params.require(:vote).permit(:restaurant_id, :voter_name, :value)
  end
end
