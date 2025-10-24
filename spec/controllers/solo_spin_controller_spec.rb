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
        expect(assigns(:service)).to be_instance_of(RestaurantService)
      end

      it 'does not set @restaurant when no location provided' do
        get :show
        expect(assigns(:restaurant)).to be_nil
      end
    end

    context 'when user is logged in' do
      let(:user) { FactoryBot.create(:user, email: 'john@example.com') }

      before { sign_in user }

      it 'renders the solo spin page' do
        get :show
        expect(response).to render_template(:show)
      end

      it 'extracts name from user email' do
        get :show
        expect(assigns(:name)).to eq("john")
      end

      it 'does not set @restaurant when no location provided' do
        get :show
        expect(assigns(:restaurant)).to be_nil
      end
    end

    context 'when location parameter is provided' do
      it 'calls restaurant service with correct params' do
        allow_any_instance_of(RestaurantService).to receive(:random_restaurant).and_return(nil)

        get :show, params: {
          location: 'New York',
          price: '$$',
          categories: 'Italian'
        }

        expect(assigns(:location)).to eq('New York')
      end
    end

    context 'when location is empty' do
      it 'sets location to empty string' do
        allow_any_instance_of(RestaurantService).to receive(:random_restaurant)

        get :show, params: { location: '', price: '$$' }

        expect(assigns(:location)).to eq('')
      end
    end

    context 'parameter handling' do
      before do
        allow_any_instance_of(RestaurantService).to receive(:random_restaurant).and_return(nil)
      end

      it 'captures location parameter' do
        get :show, params: { location: 'San Francisco' }
        expect(assigns(:location)).to eq('San Francisco')
      end

      it 'captures price parameter' do
        get :show, params: { location: 'New York', price: '$$$' }
        expect(assigns(:price)).to eq('$$$')
      end

      it 'captures categories parameter' do
        get :show, params: { location: 'New York', categories: 'Sushi, Ramen' }
        expect(assigns(:categories)).to eq('Sushi, Ramen')
      end
    end
  end
end
