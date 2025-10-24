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

      it 'extracts owner name from user email' do
        get :new
        expect(assigns(:owner_name)).to eq("maddison")
      end
    end
  end

  describe 'POST #create' do
    context 'guest user validation' do
      it 'requires owner name for guest users' do
        post :create, params: {
          owner_name: "",
          location: "New York",
          price: "$$",
          categories: "Italian"
        }

        expect(flash[:alert]).to eq("Please enter your name")
        expect(response).to redirect_to(create_room_path)
      end

      it 'requires location' do
        post :create, params: {
          owner_name: "John",
          location: "",
          price: "$$",
          categories: "Italian"
        }

        expect(flash[:alert]).to eq("Please enter a location")
        expect(response).to redirect_to(create_room_path)
      end

      it 'requires price' do
        post :create, params: {
          owner_name: "John",
          location: "New York",
          price: "",
          categories: "Italian"
        }

        expect(flash[:alert]).to eq("Please select a price range")
        expect(response).to redirect_to(create_room_path)
      end

      it 'validates price format' do
        post :create, params: {
          owner_name: "John",
          location: "New York",
          price: "$$$$$",
          categories: "Italian"
        }

        expect(flash[:alert]).to eq("Please select a valid price range")
        expect(response).to redirect_to(create_room_path)
      end

      it 'requires categories' do
        post :create, params: {
          owner_name: "John",
          location: "New York",
          price: "$$",
          categories: ""
        }

        expect(response).to redirect_to(create_room_path)
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

      it 'uses logged-in user email name instead of owner_name parameter' do
        user = create(:user, email: 'maddison@example.com', first_name: 'Maddison', last_name: 'Test')
        sign_in user

        post :create, params: {
          owner_name: "John",
          location: "New York",
          price: "$$",
          categories: "Italian"
        }

        room = Room.last
        expect(room.owner_name).to eq("maddison")
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
end
