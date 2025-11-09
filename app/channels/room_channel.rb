class RoomChannel < ApplicationCable::Channel
  def subscribed
    room_id = params[:room_id]
    stream_from "room_#{room_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
