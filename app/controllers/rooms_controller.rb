class RoomsController < ApplicationController
  def new
  end

  # This is the "Group Room" page
  def show
    @room = Room.find(params[:id])
  end

  def join
    @room = Room.find_by(code: params[:room_code])

    if @room
      if user_signed_in?
        redirect_to @room
      else
        redirect_to join_as_guest_path(@room)
      end
    else
      flash[:alert] = "Room not found"
      flash[:submitted_code] = params[:room_code]
      redirect_to root_path
    end
  end

  def join_as_guest
    @room = Room.find(params[:id])
  end
end
