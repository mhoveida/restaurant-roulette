class Room < ApplicationRecord
  # Preference validations
  validates :location,
            presence: { message: "Please enter a location" },
            format: { with: /\A[a-zA-Z\s\-]+\z/, message: "Please enter a valid location" }
  validates :price,
            presence: { message: "Please select a price range" },
            inclusion: { in: [ "$", "$$", "$$$", "$$$$" ], message: "Please select a valid price range" }
  validates :owner_name,
            presence: { message: "Please enter your name" }

  # Code validations
  validates :code,
            presence: true,
            uniqueness: true


  # State machine: waiting -> spinning -> revealing -> voting -> complete
  enum :state, {
    waiting: 0,      # Waiting for members to join
    spinning: 1,     # Members taking turns spinning
    revealing: 2,    # Showing the big reveal
    voting: 3,       # Members voting on options
    complete: 4      # Winner determined
  }

  # Callbacks
  before_validation :generate_code, on: :create
  before_create :initialize_room_state

  def add_guest_member(name, location: nil, price: nil, categories: [], member_id: nil)
    member_id ||= "guest_#{SecureRandom.hex(8)}"
    
    new_member = {
      "id" => member_id,
      "name" => name,
      "type" => "guest",
      "joined_at" => Time.current.to_s,
      "location" => location,
      "price" => price,
      "categories" => categories
    }
    
    self.members ||= []
    self.members << new_member
    save
    
    new_member
  end

  def get_all_members
    owner_member = {
      id: "owner",
      name: owner_name,
      type: "host",
      joined_at: created_at
    }
    
    member_list = [owner_member]
    if members.present?
      member_list.concat(members.map { |m| symbolize_keys(m) })
    end
    
    member_list
  end

  def get_member_by_id(member_id)
    return { id: "owner", name: owner_name, type: "host" } if member_id == "owner"
    
    member = members&.find { |m| m["id"] == member_id }
    member ? symbolize_keys(member) : nil
  end

  def start_spinning!
    return false unless waiting?
    
    # Initialize turn order with owner first, then members in join order
    self.turn_order = ["owner"]
    if members.present?
      self.turn_order += members.map { |m| m["id"] }
    end
    
    self.current_round = 1
    self.current_turn_index = 0
    self.spins = []
    self.state = :spinning
    
    save
  end

  def current_turn_member_id
    return nil unless spinning?
    turn_order[current_turn_index]
  end

  def current_turn_member
    return nil unless spinning?
    get_member_by_id(current_turn_member_id)
  end

  def is_my_turn?(member_id)
    spinning? && current_turn_member_id == member_id
  end

  def spin_for_member(member_id)
    return { success: false, error: "Not in spinning state" } unless spinning?
    return { success: false, error: "Not your turn" } unless member_id == current_turn_member_id  # FIXED
    
    # Get member's preferences - handle owner separately
    if member_id == "owner"
      member_name = owner_name
      member_location = location
      member_price = price
      member_categories = categories
    else
      member = members.find { |m| m["id"] == member_id }
      return { success: false, error: "Member not found" } unless member
      
      member_name = member["name"]
      member_location = member["location"] || location
      member_price = member["price"] || price
      member_categories = member["categories"] || categories
    end
    
    # Find restaurant with fallback
    result = find_random_restaurant(
      location: member_location,
      price: member_price,
      categories: member_categories
    )
    
    restaurant = result[:restaurant]
    match_type = result[:match_type]
    
    if restaurant.nil?
      return { success: false, error: "No restaurants found. Please try different preferences." }
    end
    
    # Store the spin result with match_type
    spin_result = {
      "member_id" => member_id,
      "member_name" => member_name,
      "restaurant" => restaurant.as_json,
      "match_type" => match_type,
      "round" => current_round,
      "spun_at" => Time.current.to_s
    }
    
    self.spins << spin_result
    
    # Move to next turn or reveal phase
    advance_turn!
    
    save
    { success: true, spin: spin_result }
  end

  def advance_turn!
    self.current_turn_index += 1
    
    # Check if round is complete
    if current_turn_index >= turn_order.length
      # Round complete - ready for reveal
      self.state = :revealing
    end
    
    save
  end

  def round_complete?
    revealing? || voting? || complete?
  end

  def get_spins_for_round(round_num)
    spins&.select { |s| s["round"] == round_num } || []
  end

  def get_revealed_spins
    spins&.select { |s| s["revealed"] == true } || []
  end

  def reveal_options!
    return false unless revealing?
    
    # Mark all spins from current round as revealed
    self.spins.each do |spin|
      if spin["round"] == current_round
        spin["revealed"] = true
      end
    end
    
    # Generate random order for display
    current_spins = get_spins_for_round(current_round)
    self.reveal_order = current_spins.each_index.to_a.shuffle
    
    # Move to voting phase
    self.state = :voting
    self.votes = {}
    
    save
  end

  def get_options_for_voting
    revealed = get_revealed_spins
    
    # Randomize order using reveal_order
    if reveal_order.present? && revealed.length == reveal_order.length
      reveal_order.map { |idx| revealed[idx] }
    else
      revealed.shuffle
    end
  end

  def vote(member_id, option_index)
    return false unless voting?
    return false unless (0...get_options_for_voting.length).include?(option_index)
    
    if votes.present? && votes[member_id.to_s].present? && votes[member_id.to_s]["confirmed"] == true
      Rails.logger.info "❌ Vote rejected - member #{member_id} already confirmed"
      return false
    end
    
    self.votes ||= {}
    self.votes[member_id.to_s] = {
      "option_index" => option_index,
      "confirmed" => false,
      "voted_at" => Time.current.to_s
    }
    
    save
  end

  def confirm_vote(member_id)
    return false unless voting?
    return false unless votes[member_id].present?
    
    self.votes[member_id]["confirmed"] = true
    save
    
    # Check if all members have confirmed votes
    check_voting_complete
  end

  def has_voted?(member_id)
    votes.present? && votes.key?(member_id.to_s)
  end

  def has_confirmed_vote?(member_id)
    votes.present? && votes.dig(member_id.to_s, "confirmed") == true
  end

  def get_member_vote(member_id)
    votes.dig(member_id.to_s, "option_index") if votes.present?
  end

  def check_voting_complete
    return false unless voting?
    
    all_members = get_all_members.map { |m| m[:id].to_s }
    confirmed_votes = votes.select { |_, v| v["confirmed"] == true }.keys
    # DEBUG
    Rails.logger.info "=== VOTING CHECK ==="
    Rails.logger.info "All members: #{all_members.inspect}"
    Rails.logger.info "Votes keys: #{votes.keys.inspect}"
    Rails.logger.info "Confirmed votes: #{confirmed_votes.inspect}"
    Rails.logger.info "===================="

    if all_members.all? { |id| confirmed_votes.include?(id) }
      # All members have confirmed - tally votes and select winner
      tally_votes_and_select_winner!
    end
  end

  def tally_votes_and_select_winner!
    return false unless voting?
    
    vote_counts = Hash.new(0)
    votes.each do |member_id, vote_data|
      next unless vote_data["confirmed"]
      option_index = vote_data["option_index"]
      vote_counts[option_index] += 1
    end
    
    return false if vote_counts.empty?
    
    max_votes = vote_counts.values.max
    tied_options = vote_counts.select { |_, count| count == max_votes }.keys
    
    if tied_options.length > 1
      winning_index = tied_options.sample
      tie_broken = true
    else
      winning_index = tied_options.first
      tie_broken = false
    end
    
    voting_options = get_options_for_voting
    winning_spin = voting_options[winning_index]
    
    self.winner = {
      "restaurant" => winning_spin["restaurant"],
      "member_id" => winning_spin["member_id"],
      "member_name" => winning_spin["member_name"],
      "match_type" => winning_spin["match_type"],  # Add this line!
      "votes" => vote_counts[winning_index],
      "total_votes" => vote_counts.values.sum,
      "tie_broken" => tie_broken,
      "tied_count" => tied_options.length,
      "selected_at" => Time.current.to_s
    }
    
    self.state = :complete
    save
  end

  def get_vote_counts
    return {} unless voting?
    
    vote_counts = Hash.new(0)
    votes.each do |_, vote_data|
      next unless vote_data["confirmed"] == true  # ✅ ONLY confirmed
      
      option_index = vote_data["option_index"]
      vote_counts[option_index] += 1
    end
    
    vote_counts
  end

  def determine_winner!
    counts = get_vote_counts
    winning_index = counts.max_by { |_k, v| v }&.first
    
    if winning_index
      revealed = get_revealed_spins
      winning_spin = revealed[winning_index]
      
      self.winner = {
        "restaurant" => winning_spin["restaurant"],
        "member_id" => winning_spin["member_id"],
        "member_name" => get_member_by_id(winning_spin["member_id"])[:name],
        "votes" => counts[winning_index],
        "total_votes" => votes.keys.length
      }
    end
    
    self.state = :complete
    save
  end

  # Additional Round Support

  def start_new_round!
    return false unless complete? || voting?
    
    # Build new turn order including ALL current members
    new_turn_order = ['owner'] + members.map { |m| m['id'] }
    
    # Update for new round
    self.turn_order = new_turn_order
    self.current_round += 1
    self.current_turn_index = 0
    self.spins = []
    self.votes = {}
    self.winner = nil
    self.reveal_order = []
    self.state = :spinning
    
    save
  end

  private

  def symbolize_keys(hash)
    if hash.is_a?(Hash)
      hash.transform_keys(&:to_sym)
    else
      hash
    end
  end

  def generate_code
    return if code.present?

    self.code = loop do
      new_code = "%04d" % rand(0..9999)
      break new_code unless Room.exists?(code: new_code)
    end
  end

  def initialize_room_state
    self.members = [] if members.nil?
    self.turn_order = []
    self.spins = []
    self.votes = {}
    self.state = :waiting
    self.current_round = 0
    self.current_turn_index = 0
  end

  def find_random_restaurant(location:, price:, categories:)
    # Try exact match first
    result = search_restaurants(location: location, price: price, categories: categories)
    return { restaurant: result, match_type: "exact" } if result
    
    # Fallback 1: Same location + price, any cuisine
    result = search_restaurants(location: location, price: price, categories: [])
    return { restaurant: result, match_type: "location_price" } if result
    
    # Fallback 2: Same location + cuisine, any price
    result = search_restaurants(location: location, price: nil, categories: categories)
    return { restaurant: result, match_type: "location_cuisine" } if result
    
    # Fallback 3: Same location only
    result = search_restaurants(location: location, price: nil, categories: [])
    return { restaurant: result, match_type: "location_only" } if result
    
    # Fallback 4: Same price + cuisine, any location
    result = search_restaurants(location: nil, price: price, categories: categories)
    return { restaurant: result, match_type: "price_cuisine" } if result
    
    # Fallback 5: Just cuisine anywhere
    result = search_restaurants(location: nil, price: nil, categories: categories)
    return { restaurant: result, match_type: "cuisine_only" } if result
    
    # Fallback 6: Just price anywhere
    result = search_restaurants(location: nil, price: price, categories: [])
    return { restaurant: result, match_type: "price_only" } if result
    
    # Last resort: Any restaurant
    result = Restaurant.order("RANDOM()").first
    return { restaurant: result, match_type: "random" } if result
    
    { restaurant: nil, match_type: "none" }
  end

  def search_restaurants(location:, price:, categories:)
    query = Restaurant.all
    
    if location.present?
      query = query.where(
        "LOWER(neighborhood) LIKE LOWER(?) OR LOWER(address) LIKE LOWER(?)",
        "%#{location}%", "%#{location}%"
      )
    end
    
    query = query.where(price: price) if price.present?
    
    if categories.present? && categories.any?
      category_conditions = categories.map { |cat| "categories LIKE ?" }
      category_values = categories.map { |cat| "%#{cat}%" }
      query = query.where(category_conditions.join(" OR "), *category_values)
    end
    
    query.order("RANDOM()").first
  end
end