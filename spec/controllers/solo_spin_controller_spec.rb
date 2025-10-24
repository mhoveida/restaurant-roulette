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
      let(:user) { create(:user, email: 'john@example.com') }

      before { sign_in user }

      it 'renders the solo spin page' do
        get :show
        expect(response).to render_template(:show)
      end

      it 'extracts name from user email' do
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

        expect(assigns(:restaurant)).to eq(restaurant)
      end

      it 'passes location parameter to service' do
        service_double = instance_double(RestaurantService)
        allow(RestaurantService).to receive(:new).and_return(service_double)
        allow(service_double).to receive(:random_restaurant).with(
          location: 'New York',
          categories: 'Italian',
          price: '$$'
        ).and_return(restaurant)

        get :show, params: {
          location: 'New York',
          price: '$$',
          categories: 'Italian'
        }

        expect(service_double).to have_received(:random_restaurant)
      end
    end

    context 'when location is empty' do
      it 'does not call random_restaurant' do
        allow_any_instance_of(RestaurantService).to receive(:random_restaurant)

        get :show, params: { location: '', price: '$$' }

        expect_any_instance_of(RestaurantService).not_to have_received(:random_restaurant)
      end
    end

    context 'parameter handling' do
      let(:restaurant) { create(:restaurant) }

      before do
        allow_any_instance_of(RestaurantService).to receive(:random_restaurant).and_return(restaurant)
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
