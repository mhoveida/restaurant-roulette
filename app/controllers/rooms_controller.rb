class RoomsController < ApplicationController
  def new
    # ⚡ Clear any previous guest name when starting fresh
    session.delete(:guest_name)
    session.delete(:joined_at)
    
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
      # Re-render the form with validation errors
      @owner_name = final_owner_name
      @location = location
      @price = price
      @categories = categories
      flash.now[:alert] = @room.errors.full_messages.join(", ")
      render :new
    end
  end

  # This is the "Group Room" page
  def show
    @room = Room.find(params[:id])

    @current_member_name =
      if current_user
        current_user.first_name
      elsif session[:guest_name].present?
        session[:guest_name]
      else
        @room.owner_name
      end
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

    if request.post?
      guest_name = params[:guest_name].to_s.strip

      if guest_name.blank?
        flash.now[:alert] = "Please enter your name"
        render :join_as_guest
        return
      end

      # Remember guest name across page reloads
      session[:guest_name] = guest_name
      session[:joined_at] = Time.current

      # Add guest to the room member list
      @room.add_guest_member(guest_name)

      redirect_to @room, notice: "Successfully joined the room!"
    end
  end

  def spin
    @room = Room.find(params[:id])

    # Fetch previously spun restaurant IDs (avoid duplicates)
    seen_ids = Array(@room.spin_results).map { |r| r["id"].to_s }

    # Try spinning up to 10 times to find a new restaurant
    max_attempts = 10
    restaurant = nil

    max_attempts.times do
      candidate = RestaurantService.new.random_restaurant(
        location: @room.location,
        categories: @room.categories,
        price: @room.price
      )

      # Skip if none found or already seen
      next if candidate.nil? || seen_ids.include?(candidate["id"].to_s)
      restaurant = candidate
      break
    end

    if restaurant
      # Append to spin_results array and persist
      @room.spin_results ||= []
      @room.spin_results << restaurant
      @room.save

      # Broadcast the result to everyone in the room via ActionCable
      ActionCable.server.broadcast("room_#{@room.id}", {
        type: "spin_result",
        restaurant: restaurant
      })

      render json: { success: true, restaurant: restaurant }
    else
      render json: {
        success: false,
        error: "no_new_restaurants",
        message: "All matching restaurants have already been suggested!"
      }, status: :ok
    end
  end

  def spin_room
    @room = Room.find(params[:id])
    @current_member_name =
      if current_user
        current_user.first_name
      elsif session[:guest_name].present?
        session[:guest_name]
      else
        @room.owner_name
      end
  end

  def start_spin
    @room = Room.find(params[:id])

    # Broadcast to all members in this room that the host started spinning
    ActionCable.server.broadcast("room_#{@room.id}", {
      type: "start_spin",
      url: group_spin_room_path(@room)
    })

    redirect_to group_spin_room_path(@room)
  end
end
