require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      let(:user) { create(:user, email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }

      let(:valid_params) do
        {
          user: {
            email: 'test@example.com',
            password: 'password123'
          }
        }
      end

      it 'sets @login_attempted to true' do
        post :create, params: valid_params
        expect(assigns(:login_attempted)).to be true
      end

      it 'handles login parameter submission' do
        post :create, params: valid_params
        # The controller sets @login_attempted = true on any POST to create
        expect(assigns(:login_attempted)).to be true
      end
    end

    context 'with invalid credentials' do
      before do
        create(:user, email: 'test@example.com', password: 'password123')
      end

      let(:invalid_params) do
        {
          user: {
            email: 'test@example.com',
            password: 'wrongpassword'
          }
        }
      end

      it 'sets @login_attempted to true' do
        post :create, params: invalid_params
        expect(assigns(:login_attempted)).to be true
      end

      it 'does not sign in the user' do
        post :create, params: invalid_params
        expect(controller.current_user).to be_nil
      end

      it 'renders the new template' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end

      it 'does not sign in on invalid credentials' do
        post :create, params: invalid_params
        # Verify user is not authenticated
        expect(controller.current_user).to be_nil
      end
    end

    context 'with missing email' do
      it 'sets @login_attempted to true' do
        post :create, params: {
          user: {
            email: '',
            password: 'password123'
          }
        }
        expect(assigns(:login_attempted)).to be true
      end

      it 'does not sign in without email' do
        post :create, params: {
          user: {
            email: '',
            password: 'password123'
          }
        }
        expect(controller.current_user).to be_nil
        expect(response).to render_template(:new)
      end

      it 'does not sign in the user' do
        post :create, params: {
          user: {
            email: '',
            password: 'password123'
          }
        }
        expect(controller.current_user).to be_nil
      end

      it 'renders the new template' do
        post :create, params: {
          user: {
            email: '',
            password: 'password123'
          }
        }
        expect(response).to render_template(:new)
      end
    end

    context 'with missing password' do
      before do
        create(:user, email: 'test@example.com', password: 'password123')
      end

      it 'sets @login_attempted to true' do
        post :create, params: {
          user: {
            email: 'test@example.com',
            password: ''
          }
        }
        expect(assigns(:login_attempted)).to be true
      end

      it 'does not sign in without password' do
        post :create, params: {
          user: {
            email: 'test@example.com',
            password: ''
          }
        }
        expect(controller.current_user).to be_nil
        expect(response).to render_template(:new)
      end

      it 'does not sign in the user' do
        post :create, params: {
          user: {
            email: 'test@example.com',
            password: ''
          }
        }
        expect(controller.current_user).to be_nil
      end

      it 'renders the new template' do
        post :create, params: {
          user: {
            email: 'test@example.com',
            password: ''
          }
        }
        expect(response).to render_template(:new)
      end
    end

    context 'with nonexistent email' do
      let(:nonexistent_params) do
        {
          user: {
            email: 'nonexistent@example.com',
            password: 'password123'
          }
        }
      end

      it 'sets @login_attempted to true' do
        post :create, params: nonexistent_params
        expect(assigns(:login_attempted)).to be true
      end

      it 'does not sign in the user' do
        post :create, params: nonexistent_params
        expect(controller.current_user).to be_nil
      end

      it 'renders the new template' do
        post :create, params: nonexistent_params
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'parameter extraction' do
    it 'extracts sign_in_params correctly' do
      user = create(:user, email: 'test@example.com', password: 'password123')
      post :create, params: {
        user: {
          email: 'test@example.com',
          password: 'password123',
          remember_me: '1'
        }
      }
      expect(controller.current_user).to eq(user)
    end

    it 'permits email, password, and remember_me parameters' do
      params_hash = { email: 'test@example.com', password: 'password123', remember_me: '1' }
      allow_any_instance_of(Users::SessionsController).to receive(:sign_in_params).and_return(params_hash)
      user = create(:user, email: 'test@example.com', password: 'password123')

      post :create, params: {
        user: {
          email: 'test@example.com',
          password: 'password123',
          remember_me: '1'
        }
      }

      expect(controller.current_user).to eq(user)
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it 'signs out the user' do
      expect(controller.current_user).to eq(user)
      delete :destroy
      expect(controller.current_user).to be_nil
    end

    it 'redirects to root path after sign out' do
      delete :destroy
      expect(response).to redirect_to(root_path)
    end

    it 'clears the session' do
      delete :destroy
      expect(controller.current_user).to be_nil
    end
  end

  describe 'layout' do
    it 'uses the application layout' do
      post :create, params: {
        user: {
          email: 'test@example.com',
          password: 'password123'
        }
      }
      expect(response).to render_template(layout: 'application')
    end
  end
end
