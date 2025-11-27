class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :join_as_guest, :start_spinning, :spin, :reveal, :vote, :confirm_vote, :status, :new_round]
  before_action :set_current_member, only: [:show, :spin, :vote, :confirm_vote]

  def neighborhoods
    neighborhoods = Restaurant.pluck(:neighborhood).uniq.compact.sort
    render json: neighborhoods
  end

  def new
    @owner_name = current_user&.first_name || ""
    @location = ""
    @price = ""
    @categories = ""
  end

  def cuisines
    cuisines = Restaurant.pluck(:categories).flatten.uniq.compact.sort
    render json: cuisines
  end

  def create
    owner_name = params[:owner_name]
    location = params[:location]
    price = params[:price]
    categories = params[:categories]

    # Use logged-in user's name if available, otherwise use provided name
    final_owner_name = user_signed_in? ? current_user.first_name : owner_name

    # Parse categories
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
      # Store room creator identifier in session
      session["member_id_for_room_#{@room.id}"] = "owner"
      redirect_to @room, notice: "Room created successfully"
    else
      @owner_name = final_owner_name
      @location = location
      @price = price
      @categories = categories
      flash.now[:alert] = @room.errors.full_messages.join(", ")
      render :new
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
        # For logged-in users, add them as a member with their user ID
        guest_name = current_user.first_name
        member_id = "user_#{current_user.id}"
        
        # Check if already in room
        unless @room.members&.any? { |m| m["id"] == member_id }
          @room.add_guest_member(guest_name, member_id: member_id)
        end
        
        session["member_id_for_room_#{@room.id}"] = member_id
        redirect_to @room, notice: "You joined the room successfully"
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
    if request.post?
      guest_name = params[:guest_name]
      location = params[:location]
      price = params[:price]
      categories_input = params[:categories]
      
      # Parse comma-separated cuisines into array
      categories = categories_input.present? ? categories_input.split(',').map(&:strip).reject(&:blank?) : []

      # Validation
      if guest_name.blank?
        flash.now[:alert] = "Please enter your name"
        render :join_as_guest
        return
      end

      if location.blank?
        flash.now[:alert] = "Please enter your location"
        render :join_as_guest
        return
      end

      if price.blank?
        flash.now[:alert] = "Please select a price range"
        render :join_as_guest
        return
      end

      if categories.empty?
        flash.now[:alert] = "Please enter at least one cuisine"
        render :join_as_guest
        return
      end

      # Add guest with their preferences
      @room.add_guest_member(guest_name, location: location, price: price, categories: categories)
      
      # Get the member ID that was just created
      new_member = @room.members.last
      session["member_id_for_room_#{@room.id}"] = new_member["id"]
      
      redirect_to @room, notice: "Successfully joined the room!"
    end
  end


  def show
  end


  def start_spinning
    if @room.start_spinning!
      # Broadcast to all members that spinning has started
      broadcast_state_change("spinning_started")
      
      render json: { success: true, state: "spinning", current_turn: @room.current_turn_member }
    else
      render json: { success: false, error: "Cannot start spinning" }, status: :unprocessable_entity
    end
  end

  def spin
    result = @room.spin_for_member(@current_member_id)
    
    if result[:success]
      # Broadcast turn change to all members
      ActionCable.server.broadcast(
        "room_#{@room.id}",
        {
          type: "turn_changed",
          current_turn: {
            member_id: @room.current_turn_member_id,
            member_name: @room.current_turn_member&.[](:name),
            turn_index: @room.current_turn_index
          },
          state: @room.state
        }
      )
      
      render json: { success: true, spin: result[:spin] }
    else
      render json: { success: false, error: result[:error] }, status: :unprocessable_entity
    end
  end


  def reveal
    if @room.reveal_options!
      # Get options in randomized order
      options = @room.get_options_for_voting
      
      # Broadcast reveal to all members
      broadcast_reveal(options)
      
      render json: {
        success: true,
        state: "voting",
        options: options.map.with_index do |spin, idx|
          {
            index: idx,
            restaurant: spin["restaurant"]
            # Note: NOT including member_id to keep it anonymous
          }
        end
      }
    else
      render json: { success: false, error: "Cannot reveal yet" }, status: :unprocessable_entity
    end
  end


  def vote
    option_index = params[:option_index].to_i
    
    Rails.logger.info "🗳️ VOTE ACTION"
    Rails.logger.info "  Member ID: #{@current_member_id.inspect}"
    Rails.logger.info "  Option: #{option_index}"
    
    if @room.vote(@current_member_id, option_index)
      Rails.logger.info "  ✅ Vote saved"
      render json: { success: true, message: "Vote recorded", current_vote: option_index }
    else
      Rails.logger.info "  ❌ Vote failed"
      render json: { success: false, error: "Could not record vote" }, status: :unprocessable_entity
    end
  end


  def confirm_vote
    if @room.confirm_vote(@current_member_id)
      # Calculate confirmed vote counts
      vote_counts = {}
      if @room.votes.present?
        @room.votes.each do |member_id, vote_data|
          next unless vote_data["confirmed"] == true
          
          option_index = vote_data["option_index"]
          vote_counts[option_index.to_s] = (vote_counts[option_index.to_s] || 0) + 1  # ← Convert to string!
        end
      end
      
      # Broadcast the updated vote counts to all members
      broadcast_vote_update(vote_counts)
      
      # Check if voting is complete and broadcast winner
      @room.reload
      if @room.complete?
        broadcast_winner(@room.winner)
      end
      
      render json: { success: true, message: "Vote confirmed!" }
    else
      render json: { success: false, error: "Could not confirm vote" }, status: :unprocessable_entity
    end
  end


  def new_round
    if @room.start_new_round!
      broadcast_state_change("new_round_started")
      render json: { success: true, round: @room.current_round, state: "spinning" }
    else
      render json: { success: false, error: "Cannot start new round" }, status: :unprocessable_entity
    end
  end


  def status
  # Calculate vote counts per option - ONLY CONFIRMED VOTES
  vote_counts = {}
  if @room.voting? && @room.votes.present?
    @room.votes.each do |member_id, vote_data|
      next unless vote_data["confirmed"] == true
      
      option_index = vote_data["option_index"]
      vote_counts[option_index.to_s] ||= 0  # Initialize to 0 if nil
      vote_counts[option_index.to_s] += 1
    end
  end
  
  render json: {
    state: @room.state,
    current_round: @room.current_round,
    current_turn: @room.spinning? ? {
      member_id: @room.current_turn_member_id,
      member_name: @room.current_turn_member[:name],
      turn_index: @room.current_turn_index
    } : nil,
    members: @room.get_all_members,
    turn_order: @room.turn_order&.map { |id| @room.get_member_by_id(id) },
    spins_count: @room.spins&.length || 0,
    votes_count: @room.votes&.keys&.length || 0,
    vote_counts_by_option: vote_counts,
    confirmed_votes_count: @room.votes&.count { |_, v| v["confirmed"] } || 0,
    winner: @room.winner
  }
end

  private

  def set_room
    @room = Room.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    if Rails.env.test? && request.xhr?
      head :not_found
      return
    end
    raise e
  end

  def set_current_member
  @current_member_id = session["member_id_for_room_#{@room.id}"]
  
  # For testing: allow override via param
  if Rails.env.test? && params[:test_creator] == 'true'
    @current_member_id = "owner"
    session["member_id_for_room_#{@room.id}"] = "owner"
  end
  
  @is_room_creator = @current_member_id == "owner"
  @current_member = @room.get_member_by_id(@current_member_id) if @current_member_id
end


  def broadcast_state_change(event_type)
    ActionCable.server.broadcast("room_#{@room.id}", {
      type: event_type,
      state: @room.state,
      data: {
        current_round: @room.current_round,
        current_turn: @room.current_turn_member
      }
    })
  end

  def broadcast_turn_update
    ActionCable.server.broadcast("room_#{@room.id}", {
      type: "turn_changed",
      current_turn: @room.current_turn_member,
      turn_index: @room.current_turn_index,
      completed_spins: @room.spins&.select { |s| s["round"] == @room.current_round }&.length
    })
  end

  def broadcast_reveal(options)
    ActionCable.server.broadcast("room_#{@room.id}", {
      type: "reveal_options",
      state: "voting",
      options: options.map.with_index do |spin, idx|
        {
          index: idx,
          restaurant: spin["restaurant"]
          # Anonymous - no member_id
        }
      end
    })
  end

  def broadcast_vote_update(vote_counts)
    ActionCable.server.broadcast("room_#{@room.id}", {
      type: "vote_update",
      vote_counts: vote_counts,
      total_votes: @room.votes&.keys&.length || 0
    })
  end

  def broadcast_winner(winner_data)
    ActionCable.server.broadcast("room_#{@room.id}", {
      type: "voting_complete",
      state: "complete",
      winner: winner_data
    })
  end
end