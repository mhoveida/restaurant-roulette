require 'rails_helper'

RSpec.describe RoomsController, type: :controller do
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
      let(:user) { create(:user, email: 'maddison@example.com', first_name: 'Maddison', last_name: 'Test') }

      before { sign_in user }

      it 'renders the new room page' do
        get :new
        expect(response).to render_template(:new)
      end

      it 'uses user first name as owner name' do
        get :new
        expect(assigns(:owner_name)).to eq("Maddison")
      end
    end
  end

  describe 'POST #create' do
    context 'guest user validation' do
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
        expect(assigns(:room).errors[:location]).to include("Please enter a location")
      end

      it 'does not create room without price' do
        expect {
          post :create, params: {
            owner_name: "John",
            location: "New York",
            price: "",
            categories: "Italian"
          }
        }.not_to change(Room, :count)

        expect(response).to render_template(:new)
        expect(assigns(:room).errors[:price]).to include("Please select a price range")
      end

      it 'does not create room with invalid price format' do
        expect {
          post :create, params: {
            owner_name: "John",
            location: "New York",
            price: "$$$$$",
            categories: "Italian"
          }
        }.not_to change(Room, :count)

        expect(response).to render_template(:new)
        expect(assigns(:room).errors[:price]).to be_present
      end

      it 'guest user can create room with all required fields' do
        expect {
          post :create, params: {
            owner_name: "John",
            location: "New York",
            price: "$$",
            categories: "Italian"
          }
        }.to change(Room, :count).by(1)

        expect(response).to redirect_to(Room.last)
      end

      it 'allows room creation without categories (optional field)' do
        expect {
          post :create, params: {
            owner_name: "John",
            location: "New York",
            price: "$$",
            categories: ""
          }
        }.to change(Room, :count).by(1)
      end
    end

    context 'successful room creation' do
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

      it 'creates a room for logged in user' do
        user = create(:user, email: 'maddison@example.com', first_name: 'Maddison', last_name: 'Test')
        sign_in user

        expect {
          post :create, params: {
            owner_name: "John",
            location: "New York",
            price: "$$",
            categories: "Italian"
          }
        }.to change(Room, :count).by(1)
      end

      it 'uses logged-in user first name instead of owner_name parameter' do
        user = create(:user, email: 'maddison@example.com', first_name: 'Maddison', last_name: 'Test')
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

      it 'accepts valid price ranges' do
        [ "$", "$$", "$$$", "$$$$" ].each do |price|
          expect {
            post :create, params: {
              owner_name: "John",
              location: "New York",
              price: price,
              categories: "Italian"
            }
          }.to change(Room, :count).by(1)
        end
      end
    end
  end

  describe 'GET #show' do
    let(:room) { FactoryBot.create(:room) }

    it 'renders the room page' do
      get :show, params: { id: room.id }
      expect(response).to render_template(:show)
    end

    it 'sets @room' do
      get :show, params: { id: room.id }
      expect(assigns(:room)).to eq(room)
    end

    it 'raises error for invalid room id' do
      expect {
        get :show, params: { id: 99999 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'POST #join' do
    let(:room) { FactoryBot.create(:room, code: "1234") }

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

      it 'rejects non-numeric codes' do
        post :join, params: { room_code: "abcd" }
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
      it 'redirects logged-in user to room' do
        user = create(:user)
        sign_in user

        post :join, params: { room_code: room.code }
        expect(response).to redirect_to(room)
      end

      it 'redirects guest user to join_as_guest page' do
        post :join, params: { room_code: room.code }
        expect(response).to redirect_to(join_as_guest_path(room))
      end
    end
  end

  describe 'GET #join_as_guest' do
    let(:room) { FactoryBot.create(:room) }

    it 'renders the join as guest page' do
      get :join_as_guest, params: { id: room.id }
      expect(response).to render_template(:join_as_guest)
    end

    it 'sets @room' do
      get :join_as_guest, params: { id: room.id }
      expect(assigns(:room)).to eq(room)
    end
  end

  describe 'POST #join_as_guest' do
    let(:room) { FactoryBot.create(:room) }

    context 'with valid guest name' do
      it 'adds guest to room members' do
        expect {
          post :join_as_guest, params: { id: room.id, guest_name: "Alex" }
        }.to change { room.reload.members.length }.by(1)

        expect(room.reload.members.last["name"]).to eq("Alex")
        expect(room.reload.members.last["type"]).to eq("guest")
      end

      it 'redirects to room page' do
        post :join_as_guest, params: { id: room.id, guest_name: "Alex" }
        expect(response).to redirect_to(room)
      end

      it 'shows success notice' do
        post :join_as_guest, params: { id: room.id, guest_name: "Alex" }
        expect(flash[:notice]).to eq("Successfully joined the room!")
      end

      it 'guest appears in get_all_members' do
        post :join_as_guest, params: { id: room.id, guest_name: "Alex" }
        members = room.reload.get_all_members
        guest_member = members.find { |m| m[:name] == "Alex" }
        expect(guest_member).to be_present
        expect(guest_member[:type]).to eq("guest")
      end
    end

    context 'with blank guest name' do
      it 'does not add guest to room' do
        expect {
          post :join_as_guest, params: { id: room.id, guest_name: "" }
        }.not_to change { room.reload.members.length }
      end

      it 'renders the join as guest page' do
        post :join_as_guest, params: { id: room.id, guest_name: "" }
        expect(response).to render_template(:join_as_guest)
      end

      it 'shows error alert' do
        post :join_as_guest, params: { id: room.id, guest_name: "" }
        expect(flash.now[:alert]).to eq("Please enter your name")
      end

      it 'sets @room' do
        post :join_as_guest, params: { id: room.id, guest_name: "" }
        expect(assigns(:room)).to eq(room)
      end
    end

    context 'with whitespace-only guest name' do
      it 'does not add guest to room' do
        expect {
          post :join_as_guest, params: { id: room.id, guest_name: "   " }
        }.not_to change { room.reload.members.length }
      end

      it 'renders the join as guest page' do
        post :join_as_guest, params: { id: room.id, guest_name: "   " }
        expect(response).to render_template(:join_as_guest)
      end
    end
  end

  describe 'POST #spin' do
    let(:room) { FactoryBot.create(:room) }
    let(:restaurant) { { name: "Test Restaurant", rating: 4.5 } }

    context 'when restaurant is found' do
      before do
        allow_any_instance_of(RestaurantService).to receive(:random_restaurant).and_return(restaurant)
        allow(ActionCable.server).to receive(:broadcast)
      end

      it 'returns success json' do
        post :spin, params: { id: room.id }, format: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["success"]).to eq(true)
      end

      it 'includes restaurant in response' do
        post :spin, params: { id: room.id }, format: :json
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["restaurant"]).to eq("name" => "Test Restaurant", "rating" => 4.5)
      end

      it 'saves spin result to room' do
        post :spin, params: { id: room.id }, format: :json
        expect(room.reload.spin_results.last)
          .to eq("name" => "Test Restaurant", "rating" => 4.5)
      end

      it 'broadcasts spin result to ActionCable' do
        expect(ActionCable.server).to receive(:broadcast).with(
          "room_#{room.id}",
          { type: "spin_result", restaurant: restaurant }
        )
        post :spin, params: { id: room.id }, format: :json
      end
    end

    context 'when no restaurant is found' do
      before do
        allow_any_instance_of(RestaurantService).to receive(:random_restaurant).and_return(nil)
      end

      it 'returns error json' do
        post :spin, params: { id: room.id }, format: :json
        expect(response).to have_http_status(:ok)

        parsed = JSON.parse(response.body)
        expect(parsed["success"]).to eq(false)
        expect(parsed["error"]).to eq("no_new_restaurants")
        expect(parsed["message"]).to eq("All matching restaurants have already been suggested!")
      end

      it 'includes error message' do
        post :spin, params: { id: room.id }, format: :json
        parsed = JSON.parse(response.body)
        expect(parsed["message"]).to eq("All matching restaurants have already been suggested!")
      end
    end
  end
end
