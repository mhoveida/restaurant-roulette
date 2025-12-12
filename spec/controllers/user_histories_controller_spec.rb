require 'rails_helper'

RSpec.describe UserHistoriesController, type: :controller do
  let(:user) { create(:user) }
  let(:restaurant) { create(:restaurant) }

  describe 'GET #show' do
    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        get :show
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is signed in' do
      before { sign_in user }

      context 'with no history' do
        it 'renders the show template' do
          get :show
          expect(response).to render_template(:show)
        end

        it 'sets empty restaurants list' do
          get :show
          expect(assigns(:restaurants)).to eq([])
        end
      end

      context 'with history' do
        before do
          create(:user_restaurant_history, user: user, restaurant: restaurant)
        end

        it 'renders the show template' do
          get :show
          expect(response).to render_template(:show)
        end

        it 'includes restaurants in @restaurants' do
          get :show
          expect(assigns(:restaurants)).to include(restaurant)
        end

        it 'orders histories by most recent first' do
          old_history = create(:user_restaurant_history, user: user, created_at: 1.day.ago)
          new_history = create(:user_restaurant_history, user: user)

          get :show
          histories = assigns(:histories)
          expect(histories.first.id).to eq(new_history.id)
          expect(histories.last.id).to eq(old_history.id)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before { sign_in user }

    context 'with valid restaurant_id' do
      before do
        create(:user_restaurant_history, user: user, restaurant: restaurant)
      end

      it 'removes the restaurant from history' do
        expect {
          delete :destroy, params: { restaurant_id: restaurant.id }
        }.to change(UserRestaurantHistory, :count).by(-1)
      end

      it 'returns success response' do
        delete :destroy, params: { restaurant_id: restaurant.id }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['success']).to eq(true)
      end

      it 'only removes for current user' do
        other_user = create(:user)
        create(:user_restaurant_history, user: other_user, restaurant: restaurant)

        delete :destroy, params: { restaurant_id: restaurant.id }

        expect(user.user_restaurant_histories.count).to eq(0)
        expect(other_user.user_restaurant_histories.count).to eq(1)
      end
    end

    context 'with invalid restaurant_id' do
      it 'returns not found response' do
        delete :destroy, params: { restaurant_id: 99999 }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['success']).to eq(false)
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        sign_out user
        delete :destroy, params: { restaurant_id: restaurant.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
