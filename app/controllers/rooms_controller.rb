class RoomsController < ApplicationController
  def new
  end

  # This is the "Group Room" page
  def show
    @room = Room.find(params[:id])
  end

  def join
    room_code = params[:room_code]
    if room_code.blank?
      flash[:alert] = "Please enter a room code"
      redirect_to root_path
      return

    elsif !room_code.match?(/^\d{4}$/)
      flash[:alert] = "Please enter a valid 4-digit room code"
      flash[:submitted_code] = room_code
      redirect_to root_path
      return

    end

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
