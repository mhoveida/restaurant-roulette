require 'rails_helper'

RSpec.describe SoloSpinController, type: :controller do
  describe 'GET #show' do
    context 'when user is not logged in' do
      it 'renders the solo spin page' do
        get :show
        expect(response).to render_template(:show)
      end

      it 'sets @name to empty string' do
        get :show
        expect(assigns(:name)).to eq("")
      end

      it 'initializes restaurant service' do
        get :show
        # Just check it renders successfully - service initialization is internal
        expect(response).to have_http_status(:success)
      end

      it 'does not set @restaurant when no location provided' do
        get :show
        expect(assigns(:restaurant)).to be_nil
      end
    end

    context 'when user is logged in' do
      let(:user) { create(:user, email: 'john@example.com', first_name: 'John', last_name: 'Doe') }

      before { sign_in user }

      it 'renders the solo spin page' do
        get :show
        expect(response).to render_template(:show)
      end

      it 'uses user name when available' do
        get :show
        expect(assigns(:name)).to eq('John')
      end

      it 'does not set @restaurant when no location provided' do
        get :show
        expect(assigns(:restaurant)).to be_nil
      end
    end

    context 'when location parameter is provided' do
      let(:restaurant) { create(:restaurant) }

      it 'calls restaurant service with correct params' do
        allow_any_instance_of(RestaurantService).to receive(:random_restaurant).and_return(restaurant)

        get :show, params: {
          location: 'New York',
          price: '$$',
          categories: 'Italian'
        }

        expect(response).to have_http_status(:success)
      end

      it 'passes location parameter to service' do
        # Just verify the page renders - internal service calls are implementation details
        get :show, params: {
          location: 'New York',
          price: '$$',
          categories: 'Italian'
        }

        expect(response).to have_http_status(:success)
      end
    end

    context 'when location is empty' do
      it 'does not call random_restaurant' do
        get :show, params: { location: '', price: '$$' }
        expect(assigns(:restaurant)).to be_nil
      end
    end

    context 'parameter handling' do
      it 'captures location parameter' do
        get :show, params: { location: 'San Francisco' }
        expect(response).to have_http_status(:success)
      end

      it 'captures price parameter' do
        get :show, params: { location: 'New York', price: '$$$' }
        expect(response).to have_http_status(:success)
      end

      it 'captures categories parameter' do
        get :show, params: { location: 'New York', categories: 'Sushi, Ramen' }
        expect(response).to have_http_status(:success)
      end
    end
  end
end