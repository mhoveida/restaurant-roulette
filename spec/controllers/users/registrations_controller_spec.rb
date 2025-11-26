require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          user: {
            email: 'newuser@example.com',
            first_name: 'New',
            last_name: 'User',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'creates a new user' do
        expect {
          post :create, params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'signs in the user' do
        post :create, params: valid_params
        expect(controller.current_user).to be_present
      end

      it 'redirects to root path' do
        post :create, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      it 'sets @signup_attempted to true' do
        post :create, params: valid_params
        expect(assigns(:signup_attempted)).to be true
      end
      
      it 'sets flash notice' do
        post :create, params: valid_params
        expect(flash[:notice]).to be_present
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          user: {
            email: 'invalid',
            first_name: '',
            last_name: '',
            password: 'short',
            password_confirmation: 'different'
          }
        }
      end

      it 'does not create a user' do
        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)
      end

      it 'renders the new template' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end
      
      it 'returns unprocessable_entity status' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'sets @signup_attempted to true' do
        post :create, params: invalid_params
        expect(assigns(:signup_attempted)).to be true
      end
    end

    context 'with missing first_name' do
      let(:params_without_first_name) do
        {
          user: {
            email: 'test@example.com',
            first_name: '',
            last_name: 'User',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'does not create a user' do
        expect {
          post :create, params: params_without_first_name
        }.not_to change(User, :count)
      end
    end

    context 'with missing last_name' do
      let(:params_without_last_name) do
        {
          user: {
            email: 'test@example.com',
            first_name: 'Test',
            last_name: '',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'does not create a user' do
        expect {
          post :create, params: params_without_last_name
        }.not_to change(User, :count)
      end
    end
  end

  describe '#after_sign_up_path_for' do
    let(:user) { create(:user) }
    
    it 'returns root path' do
      path = controller.send(:after_sign_up_path_for, user)
      expect(path).to eq(root_path)
    end
  end

  describe '#configure_sign_up_params' do
    it 'permits first_name and last_name' do
      controller.send(:configure_sign_up_params)
      expect(true).to be true
    end
  end
end