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

    # Validate owner name (required for guests, used for logged-in users)
    if owner_name.blank? && !user_signed_in?
      flash[:alert] = "Please enter your name"
      redirect_to create_room_path
      return
    end

    # Validate location
    if location.blank?
      flash[:alert] = "Please enter a location"
      redirect_to create_room_path
      return
    end

    # Validate price
    if price.blank?
      flash[:alert] = "Please select a price range"
      redirect_to create_room_path
      return
    end

    # Validate price format
    unless [ "$", "$$", "$$$", "$$$$" ].include?(price)
      flash[:alert] = "Please select a valid price range"
      redirect_to create_room_path
      return
    end


    # Use logged-in user's name if available, otherwise use provided name
    final_owner_name = user_signed_in? ? (current_user.email.split("@").first) : owner_name

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
      redirect_to create_room_path
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
