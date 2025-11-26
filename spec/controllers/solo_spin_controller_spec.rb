require 'rails_helper'

RSpec.describe SoloSpinController, type: :controller do
  let(:restaurant) { create(:restaurant, name: "Test Restaurant", neighborhood: "SoHo") }

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
    end

    context 'when user is logged in' do
      let(:user) { create(:user, first_name: 'John') }

      before { sign_in user }

      it 'renders the solo spin page' do
        get :show
        expect(response).to render_template(:show)
      end

      it 'uses user name when available' do
        get :show
        expect(assigns(:name)).to eq('John')
      end
    end
  end
  
  describe 'POST #spin' do
    before do
      allow_any_instance_of(Restaurant).to receive(:as_json).and_return({
        "id" => restaurant.id,
        "name" => restaurant.name,
        "rating" => restaurant.rating,
        "price" => restaurant.price
      })
    end

    context 'when restaurant is found' do
      before do
        allow_any_instance_of(SoloSpinController).to receive(:find_random_restaurant).and_return({
          restaurant: restaurant,
          match_type: "exact"
        })
      end

      it 'returns success with restaurant' do
        post :spin, params: {
          location: 'New York',
          price: '$$',
          categories: ['Italian']
        }
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["success"]).to be true
        expect(json["restaurant"]).to be_present
      end
      
      it 'includes match_type in response' do
        post :spin, params: {
          location: 'New York',
          price: '$$',
          categories: ['Italian']
        }
        
        json = JSON.parse(response.body)
        expect(json["match_type"]).to eq("exact")
      end
      
      it 'handles array categories parameter' do
        post :spin, params: {
          location: 'New York',
          price: '$$',
          categories: ['Italian', 'French']
        }
        
        expect(response).to have_http_status(:ok)
      end
      
      it 'handles string categories parameter' do
        post :spin, params: {
          location: 'New York',
          price: '$$',
          categories: 'Italian'
        }
        
        expect(response).to have_http_status(:ok)
      end
      
      it 'handles nil categories' do
        post :spin, params: {
          location: 'New York',
          price: '$$'
        }
        
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when no restaurant is found' do
      before do
        allow_any_instance_of(SoloSpinController).to receive(:find_random_restaurant).and_return({
          restaurant: nil,
          match_type: "none"
        })
      end

      it 'returns error response' do
        post :spin, params: {
          location: 'Mars',
          price: '$$$$',
          categories: ['Martian']
        }
        
        json = JSON.parse(response.body)
        expect(json["success"]).to be false
        expect(json["error"]).to be_present
      end
    end
  end
  
  # Test private methods
  describe '#find_random_restaurant' do
    let(:controller_instance) { SoloSpinController.new }
    
    context 'with exact match' do
      it 'returns exact match type' do
        allow(controller_instance).to receive(:search_restaurants).with(
          location: 'SoHo',
          price: '$$',
          categories: ['Italian']
        ).and_return(restaurant)
        
        result = controller_instance.send(:find_random_restaurant,
          location: 'SoHo',
          price: '$$',
          categories: ['Italian']
        )
        
        expect(result[:restaurant]).to eq(restaurant)
        expect(result[:match_type]).to eq('exact')
      end
    end
    
    context 'with location_price fallback' do
      it 'returns location_price match type' do
        allow(controller_instance).to receive(:search_restaurants).with(
          location: 'SoHo',
          price: '$$',
          categories: ['Italian']
        ).and_return(nil)
        
        allow(controller_instance).to receive(:search_restaurants).with(
          location: 'SoHo',
          price: '$$',
          categories: []
        ).and_return(restaurant)
        
        result = controller_instance.send(:find_random_restaurant,
          location: 'SoHo',
          price: '$$',
          categories: ['Italian']
        )
        
        expect(result[:restaurant]).to eq(restaurant)
        expect(result[:match_type]).to eq('location_price')
      end
    end
    
    context 'with location_cuisine fallback' do
      it 'returns location_cuisine match type' do
        allow(controller_instance).to receive(:search_restaurants).and_return(nil, nil)
        
        allow(controller_instance).to receive(:search_restaurants).with(
          location: 'SoHo',
          price: nil,
          categories: ['Italian']
        ).and_return(restaurant)
        
        result = controller_instance.send(:find_random_restaurant,
          location: 'SoHo',
          price: '$$',
          categories: ['Italian']
        )
        
        expect(result[:restaurant]).to eq(restaurant)
        expect(result[:match_type]).to eq('location_cuisine')
      end
    end
    
    context 'with location_only fallback' do
      it 'returns location_only match type' do
        allow(controller_instance).to receive(:search_restaurants).and_return(nil, nil, nil)
        
        allow(controller_instance).to receive(:search_restaurants).with(
          location: 'SoHo',
          price: nil,
          categories: []
        ).and_return(restaurant)
        
        result = controller_instance.send(:find_random_restaurant,
          location: 'SoHo',
          price: '$$',
          categories: ['Italian']
        )
        
        expect(result[:restaurant]).to eq(restaurant)
        expect(result[:match_type]).to eq('location_only')
      end
    end
    
    context 'with price_cuisine fallback' do
      it 'returns price_cuisine match type' do
        allow(controller_instance).to receive(:search_restaurants).and_return(nil, nil, nil, nil)
        
        allow(controller_instance).to receive(:search_restaurants).with(
          location: nil,
          price: '$$',
          categories: ['Italian']
        ).and_return(restaurant)
        
        result = controller_instance.send(:find_random_restaurant,
          location: 'SoHo',
          price: '$$',
          categories: ['Italian']
        )
        
        expect(result[:restaurant]).to eq(restaurant)
        expect(result[:match_type]).to eq('price_cuisine')
      end
    end
    
    context 'with cuisine_only fallback' do
      it 'returns cuisine_only match type' do
        allow(controller_instance).to receive(:search_restaurants).and_return(nil, nil, nil, nil, nil)
        
        allow(controller_instance).to receive(:search_restaurants).with(
          location: nil,
          price: nil,
          categories: ['Italian']
        ).and_return(restaurant)
        
        result = controller_instance.send(:find_random_restaurant,
          location: 'SoHo',
          price: '$$',
          categories: ['Italian']
        )
        
        expect(result[:restaurant]).to eq(restaurant)
        expect(result[:match_type]).to eq('cuisine_only')
      end
    end
    
    context 'with price_only fallback' do
      it 'returns price_only match type' do
        allow(controller_instance).to receive(:search_restaurants).and_return(nil, nil, nil, nil, nil, nil)
        
        allow(controller_instance).to receive(:search_restaurants).with(
          location: nil,
          price: '$$',
          categories: []
        ).and_return(restaurant)
        
        result = controller_instance.send(:find_random_restaurant,
          location: 'SoHo',
          price: '$$',
          categories: ['Italian']
        )
        
        expect(result[:restaurant]).to eq(restaurant)
        expect(result[:match_type]).to eq('price_only')
      end
    end
    
    context 'with random fallback' do
      it 'returns random match type' do
        allow(controller_instance).to receive(:search_restaurants).and_return(nil)
        allow(Restaurant).to receive_message_chain(:order, :first).and_return(restaurant)
        
        result = controller_instance.send(:find_random_restaurant,
          location: 'SoHo',
          price: '$$',
          categories: ['Italian']
        )
        
        expect(result[:restaurant]).to eq(restaurant)
        expect(result[:match_type]).to eq('random')
      end
    end
    
    context 'with no restaurants' do
      it 'returns none match type' do
        allow(controller_instance).to receive(:search_restaurants).and_return(nil)
        allow(Restaurant).to receive_message_chain(:order, :first).and_return(nil)
        
        result = controller_instance.send(:find_random_restaurant,
          location: 'SoHo',
          price: '$$',
          categories: ['Italian']
        )
        
        expect(result[:restaurant]).to be_nil
        expect(result[:match_type]).to eq('none')
      end
    end
  end
  
  describe '#search_restaurants' do
    let(:controller_instance) { SoloSpinController.new }
    
    it 'searches with all parameters' do
      create(:restaurant, neighborhood: 'SoHo', price: '$$', categories: ['Italian'])
      
      result = controller_instance.send(:search_restaurants,
        location: 'SoHo',
        price: '$$',
        categories: ['Italian']
      )
      
      expect(result).to be_present
    end
    
    it 'searches with location only' do
      create(:restaurant, neighborhood: 'SoHo')
      
      result = controller_instance.send(:search_restaurants,
        location: 'SoHo',
        price: nil,
        categories: []
      )
      
      expect(result).to be_present
    end
    
    it 'searches with price only' do
      create(:restaurant, price: '$$')
      
      result = controller_instance.send(:search_restaurants,
        location: nil,
        price: '$$',
        categories: []
      )
      
      expect(result).to be_present
    end
    
    it 'searches with categories only' do
      create(:restaurant, categories: ['Italian'])
      
      result = controller_instance.send(:search_restaurants,
        location: nil,
        price: nil,
        categories: ['Italian']
      )
      
      expect(result).to be_present
    end
    
    it 'handles multiple categories' do
      create(:restaurant, categories: ['Italian', 'French'])
      
      result = controller_instance.send(:search_restaurants,
        location: nil,
        price: nil,
        categories: ['Italian', 'French']
      )
      
      expect(result).to be_present
    end
    
    it 'returns nil when no match found' do
      result = controller_instance.send(:search_restaurants,
        location: 'Mars',
        price: '$$$$$',
        categories: ['Alien']
      )
      
      expect(result).to be_nil
    end
    
    it 'handles empty categories array' do
      create(:restaurant, neighborhood: 'SoHo')
      
      result = controller_instance.send(:search_restaurants,
        location: 'SoHo',
        price: nil,
        categories: []
      )
      
      expect(result).to be_present
    end
    
    it 'handles nil location' do
      create(:restaurant, price: '$$')
      
      result = controller_instance.send(:search_restaurants,
        location: nil,
        price: '$$',
        categories: []
      )
      
      expect(result).to be_present
    end
    
    it 'handles nil price' do
      create(:restaurant, neighborhood: 'SoHo')
      
      result = controller_instance.send(:search_restaurants,
        location: 'SoHo',
        price: nil,
        categories: []
      )
      
      expect(result).to be_present
    end
  end
end