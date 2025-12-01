require 'rails_helper'

RSpec.describe RoomsController, type: :controller do
  let(:restaurant) { create(:restaurant) }

  before do
    allow_any_instance_of(Restaurant).to receive(:as_json).and_return({
      "id" => restaurant.id,
      "name" => restaurant.name,
      "rating" => restaurant.rating,
      "price" => restaurant.price,
      "address" => restaurant.address,
      "categories" => restaurant.categories
    })
  end

  describe 'GET #neighborhoods' do
    it 'returns neighborhoods as json' do
      create(:restaurant, neighborhood: 'SoHo')
      get :neighborhoods
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to include('SoHo')
    end
  end

  describe 'GET #cuisines' do
    it 'returns cuisines as json' do
      create(:restaurant, categories: [ 'Italian', 'Pizza' ])
      get :cuisines
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to include('Italian', 'Pizza')
    end
  end

  describe 'GET #new' do
    context 'when user is not logged in' do
      it 'renders the new room page' do
        get :new
        expect(response).to render_template(:new)
      end

      it 'sets @owner_name to empty string' do
        get :new
        expect(assigns(:owner_name)).to eq("")
      end

      it 'initializes empty preferences' do
        get :new
        expect(assigns(:location)).to eq("")
        expect(assigns(:price)).to eq("")
        expect(assigns(:categories)).to eq("")
      end
    end

    context 'when user is logged in' do
      let(:user) { create(:user, first_name: 'Maddison') }

      before { sign_in user }

      it 'uses user first name as owner name' do
        get :new
        expect(assigns(:owner_name)).to eq("Maddison")
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a room for guest user' do
        expect {
          post :create, params: {
            owner_name: "John",
            location: "New York",
            price: "$$",
            categories: "Italian"
          }
        }.to change(Room, :count).by(1)
      end

      it 'uses logged-in user first name' do
        user = create(:user, first_name: 'Maddison')
        sign_in user

        post :create, params: {
          owner_name: "John",
          location: "New York",
          price: "$$",
          categories: "Italian"
        }

        room = Room.last
        expect(room.owner_name).to eq("Maddison")
      end

      it 'redirects to room show page' do
        post :create, params: {
          owner_name: "John",
          location: "New York",
          price: "$$",
          categories: "Italian"
        }

        expect(response).to redirect_to(Room.last)
      end

      it 'sets session member_id' do
        post :create, params: {
          owner_name: "John",
          location: "New York",
          price: "$$",
          categories: "Italian"
        }

        room = Room.last
        expect(session["member_id_for_room_#{room.id}"]).to eq("owner")
      end

      it 'parses comma-separated categories' do
        post :create, params: {
          owner_name: "John",
          location: "New York",
          price: "$$",
          categories: "Italian, French, Mexican"
        }

        room = Room.last
        expect(room.categories).to eq([ "Italian", "French", "Mexican" ])
      end
    end

    context 'with invalid parameters' do
      it 'does not create room without location' do
        expect {
          post :create, params: {
            owner_name: "John",
            location: "",
            price: "$$",
            categories: "Italian"
          }
        }.not_to change(Room, :count)

        expect(response).to render_template(:new)
      end
    end
  end

  describe 'POST #join' do
    let(:room) { create(:room, code: "1234") }

    context 'validation' do
      it 'requires room code' do
        post :join, params: { room_code: "" }
        expect(flash[:alert]).to eq("Please enter a room code")
        expect(response).to redirect_to(root_path)
      end

      it 'requires 4-digit format' do
        post :join, params: { room_code: "123" }
        expect(flash[:alert]).to eq("Please enter a valid 4-digit room code")
        expect(response).to redirect_to(root_path)
      end

      it 'handles room not found' do
        post :join, params: { room_code: "9999" }
        expect(flash[:alert]).to eq("Room not found")
        expect(response).to redirect_to(root_path)
      end
    end

    context 'successful join' do
      it 'redirects logged-in user to room and adds to members' do
        user = create(:user, first_name: 'Test')
        sign_in user

        post :join, params: { room_code: room.code }
        expect(response).to redirect_to(room)

        member_id = "user_#{user.id}"
        expect(session["member_id_for_room_#{room.id}"]).to eq(member_id)
      end

      it 'redirects guest user to join_as_guest page' do
        post :join, params: { room_code: room.code }
        expect(response).to redirect_to(join_as_guest_path(room))
      end
    end
  end

  describe 'POST #join_as_guest' do
    let(:room) { create(:room) }

    context 'with valid guest data' do
      it 'adds guest with preferences' do
        expect {
          post :join_as_guest, params: {
            id: room.id,
            guest_name: "Alex",
            location: "Brooklyn",
            price: "$$$",
            categories: "Italian, French"
          }
        }.to change { room.reload.get_all_members.length }.by(1)
      end

      it 'redirects to room page' do
        post :join_as_guest, params: {
          id: room.id,
          guest_name: "Alex",
          location: "Brooklyn",
          price: "$$$",
          categories: "Italian"
        }
        expect(response).to redirect_to(room)
      end

      it 'sets session for guest member' do
        post :join_as_guest, params: {
          id: room.id,
          guest_name: "Alex",
          location: "Brooklyn",
          price: "$$$",
          categories: "Italian"
        }
        expect(session["member_id_for_room_#{room.id}"]).to be_present
      end
    end

    context 'with missing data' do
      it 'rejects blank name' do
        post :join_as_guest, params: {
          id: room.id,
          guest_name: "",
          location: "Brooklyn",
          price: "$$$",
          categories: "Italian"
        }
        expect(response).to render_template(:join_as_guest)
        expect(flash.now[:alert]).to match(/name/i)
      end

      it 'rejects blank location' do
        post :join_as_guest, params: {
          id: room.id,
          guest_name: "Alex",
          location: "",
          price: "$$$",
          categories: "Italian"
        }
        expect(response).to render_template(:join_as_guest)
        expect(flash.now[:alert]).to match(/location/i)
      end

      it 'rejects blank price' do
        post :join_as_guest, params: {
          id: room.id,
          guest_name: "Alex",
          location: "Brooklyn",
          price: "",
          categories: "Italian"
        }
        expect(response).to render_template(:join_as_guest)
        expect(flash.now[:alert]).to match(/price/i)
      end

      it 'rejects empty categories' do
        post :join_as_guest, params: {
          id: room.id,
          guest_name: "Alex",
          location: "Brooklyn",
          price: "$$$",
          categories: ""
        }
        expect(response).to render_template(:join_as_guest)
        expect(flash.now[:alert]).to match(/cuisine/i)
      end
    end
  end

  describe 'GET #show' do
    let(:room) { create(:room) }

    it 'renders the room page' do
      get :show, params: { id: room.id }
      expect(response).to render_template(:show)
    end

    it 'sets @room' do
      get :show, params: { id: room.id }
      expect(assigns(:room)).to eq(room)
    end

    it 'sets @current_member_id from session' do
      session["member_id_for_room_#{room.id}"] = "test_member"
      get :show, params: { id: room.id }
      expect(assigns(:current_member_id)).to eq("test_member")
    end

    it 'sets @is_room_creator for owner' do
      session["member_id_for_room_#{room.id}"] = "owner"
      get :show, params: { id: room.id }
      expect(assigns(:is_room_creator)).to be true
    end
  end

  describe 'POST #start_spinning' do
    let(:room) { create(:room) }

    before do
      session["member_id_for_room_#{room.id}"] = "owner"
    end

    it 'transitions room to spinning state' do
      post :start_spinning, params: { id: room.id }
      expect(room.reload.spinning?).to be true
    end

    it 'returns success json' do
      post :start_spinning, params: { id: room.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
    end
  end

  describe 'POST #spin' do
    let(:room) { create(:room) }

    before do
      room.update!(state: :spinning, turn_order: [ "owner" ], current_turn_index: 0, current_round: 1)
      session["member_id_for_room_#{room.id}"] = "owner"
      allow_any_instance_of(Room).to receive(:find_random_restaurant).and_return({
        restaurant: restaurant,
        match_type: "exact"
      })
    end

    it 'returns success json' do
      post :spin, params: { id: room.id }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
    end

    it 'includes spin data' do
      post :spin, params: { id: room.id }, format: :json
      json = JSON.parse(response.body)
      expect(json["spin"]).to be_present
      expect(json["spin"]["restaurant"]).to be_present
    end

    context 'when not authenticated' do
      before do
        session.delete("member_id_for_room_#{room.id}")
      end

      it 'returns unprocessable content when not authenticated' do
        post :spin, params: { id: room.id }, format: :json
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'POST #reveal' do
    let(:room) { create(:room) }

    before do
      room.update!(
        state: :revealing,
        spins: [ { "member_id" => "owner", "restaurant" => { "name" => "Test" }, "round" => 1 } ],
        current_round: 1
      )
      session["member_id_for_room_#{room.id}"] = "owner"
    end

    it 'transitions to voting state' do
      post :reveal, params: { id: room.id }
      expect(room.reload.voting?).to be true
    end

    it 'returns options' do
      post :reveal, params: { id: room.id }
      json = JSON.parse(response.body)
      expect(json["options"]).to be_an(Array)
    end
  end

  describe 'POST #vote' do
    let(:room) { create(:room) }

    before do
      room.update!(
        state: :revealing,
        spins: [ { "member_id" => "owner", "restaurant" => { "name" => "Test" }, "round" => 1 } ],
        current_round: 1
      )
      room.reveal_options!
      room.reload
      session["member_id_for_room_#{room.id}"] = "owner"
    end

    it 'records vote' do
      post :vote, params: { id: room.id, option_index: 0 }, format: :json
      expect(response).to have_http_status(:ok)
      expect(room.reload.votes["owner"]).to be_present
    end
  end

  describe 'POST #confirm_vote' do
    let(:room) { create(:room) }

    before do
      # Properly setup with reveal_options! to ensure reveal_order is set
      room.update!(
        state: :revealing,
        spins: [ { "member_id" => "owner", "restaurant" => { "name" => "Test" }, "round" => 1 } ],
        current_round: 1
      )
      room.reveal_options!  # This properly sets revealed=true and reveal_order
      room.reload

      session["member_id_for_room_#{room.id}"] = "owner"
      room.vote("owner", 0)
    end

    it 'confirms vote' do
      post :confirm_vote, params: { id: room.id }, format: :json
      expect(response).to have_http_status(:ok)
      expect(room.reload.has_confirmed_vote?("owner")).to be true
    end
  end

  describe 'POST #new_round' do
    let(:room) { create(:room) }

    before do
      room.update!(state: :complete)
      session["member_id_for_room_#{room.id}"] = "owner"
    end

    it 'starts new round' do
      post :new_round, params: { id: room.id }
      expect(response).to have_http_status(:ok)
      expect(room.reload.spinning?).to be true
    end
  end

  describe 'GET #status' do
    let(:room) { create(:room) }

    it 'returns room status as json' do
      get :status, params: { id: room.id }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["state"]).to eq(room.state)
    end

    it 'includes vote counts' do
      room.update!(state: :voting, votes: { "owner" => { "option_index" => 0 } })
      get :status, params: { id: room.id }, format: :json
      json = JSON.parse(response.body)
      expect(json).to have_key("vote_counts_by_option")
    end
  end
end
