require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:valid_params) do
        {
          user: {
            first_name: 'John',
            last_name: 'Doe',
            email: 'john.doe@example.com',
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

      it 'sets @signup_attempted to true' do
        post :create, params: valid_params
        expect(assigns(:signup_attempted)).to be true
      end

      it 'creates user with correct attributes' do
        post :create, params: valid_params
        user = User.last
        expect(user.first_name).to eq('John')
        expect(user.last_name).to eq('Doe')
        expect(user.email).to eq('john.doe@example.com')
      end

      it 'signs the user in after successful registration' do
        post :create, params: valid_params
        expect(controller.current_user).to be_a(User)
        expect(controller.current_user.email).to eq('john.doe@example.com')
      end
    end

    context 'with invalid attributes' do
      let(:invalid_params) do
        {
          user: {
            first_name: '',
            last_name: 'Doe',
            email: 'invalid-email',
            password: 'short',
            password_confirmation: 'mismatch'
          }
        }
      end

      it 'does not create a new user' do
        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)
      end

      it 'sets @signup_attempted to true' do
        post :create, params: invalid_params
        expect(assigns(:signup_attempted)).to be true
      end

      it 'renders the new template' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end

      it 'renders the new template with errors' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end
    end

    context 'with missing required fields' do
      it 'fails when first_name is missing' do
        expect {
          post :create, params: {
            user: {
              last_name: 'Doe',
              email: 'test@example.com',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        }.not_to change(User, :count)
      end

      it 'fails when last_name is missing' do
        expect {
          post :create, params: {
            user: {
              first_name: 'John',
              email: 'test@example.com',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        }.not_to change(User, :count)
      end

      it 'fails when email is missing' do
        post :create, params: {
          user: {
            first_name: 'John',
            last_name: 'Doe',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
        expect { post :create }.not_to change(User, :count)
      end

      it 'fails when password is missing' do
        post :create, params: {
          user: {
            first_name: 'John',
            last_name: 'Doe',
            email: 'test@example.com',
            password_confirmation: 'password123'
          }
        }
        expect(response).not_to be_redirect
      end
    end

    context 'with duplicate email' do
      before do
        create(:user, email: 'existing@example.com')
      end

      it 'does not create a new user' do
        expect {
          post :create, params: {
            user: {
              first_name: 'Jane',
              last_name: 'Smith',
              email: 'existing@example.com',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        }.not_to change(User, :count)
      end

      it 'renders the new template with error' do
        post :create, params: {
          user: {
            first_name: 'Jane',
            last_name: 'Smith',
            email: 'existing@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'parameter sanitization' do
    it 'accepts first_name and last_name in signup' do
      expect {
        post :create, params: {
          user: {
            first_name: 'John',
            last_name: 'Doe',
            email: 'permitted@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      }.to change(User, :count).by(1)

      user = User.last
      expect(user.first_name).to eq('John')
      expect(user.last_name).to eq('Doe')
    end
  end
end
