require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'GET #google_oauth2' do
    let(:auth_hash) do
      OmniAuth::AuthHash.new({
        provider: 'google_oauth2',
        uid: '123456789',
        info: {
          email: 'test@example.com',
          first_name: 'Test',
          last_name: 'User'
        }
      })
    end

    before do
      request.env['omniauth.auth'] = auth_hash
    end

    context 'when user does not exist' do
      it 'creates a new user' do
        expect {
          get :google_oauth2
        }.to change(User, :count).by(1)
      end

      it 'signs in the user' do
        get :google_oauth2
        expect(controller.current_user).to be_present
      end

      it 'redirects to root path' do
        get :google_oauth2
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user already exists' do
      let!(:existing_user) { User.from_omniauth(auth_hash) }

      it 'does not create a new user' do
        expect {
          get :google_oauth2
        }.not_to change(User, :count)
      end

      it 'signs in the existing user' do
        get :google_oauth2
        expect(controller.current_user).to eq(existing_user)
      end
    end
  end

  describe 'GET #failure' do
    it 'redirects to root path' do
      get :failure
      expect(response).to redirect_to(root_path)
    end

    it 'sets alert message' do
      get :failure, params: { message: 'invalid_credentials' }
      expect(flash[:alert]).to be_present
    end
  end
end
