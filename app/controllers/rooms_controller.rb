class RoomsController < ApplicationController
  def new
    @owner_name = current_user&.first_name || ""
    @location = ""
    @price = ""
    @categories = ""
  end

  def create
    owner_name = params[:owner_name]
    location = params[:location]
    price = params[:price]
    categories = params[:categories]

    # Use logged-in user's name if available, otherwise use provided name
    final_owner_name = user_signed_in? ? current_user.first_name : owner_name

    # Parse categories - convert comma-separated string to array, or empty array if blank
    categories_array = if categories.present?
      categories.split(",").map(&:strip).reject(&:empty?)
    else
      []
    end

    # Create the room
    @room = Room.new(
      owner_name: final_owner_name,
      location: location,
      price: price,
      categories: categories_array
    )

    if @room.save
      redirect_to @room, notice: "Room created successfully"
    else
      flash[:alert] = @room.errors.full_messages.join(", ")
      redirect_to rooms_new_path
    end
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
