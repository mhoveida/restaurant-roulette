# spec/requests/users/omniauth_callbacks_spec.rb
require "rails_helper"

RSpec.describe "Users::OmniauthCallbacks", type: :request do
  before do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "1234567890",
      info: {
        email: "testuser@columbia.edu",
        name: "Test User"
      },
      credentials: {
        token: "mock_token",
        refresh_token: "mock_refresh_token",
        expires_at: Time.now + 1.week
      }
    )
  end

  describe "GET /users/auth/google_oauth2/callback" do
    it "logs in the user and redirects" do
      get user_google_oauth2_omniauth_callback_path

      # Check that the user was created or found
      user = User.find_by(email: "testuser@columbia.edu")
      expect(user).not_to be_nil

      # Check redirection (Devise default after_sign_in_path)
      expect(response).to redirect_to(root_path)
    end
  end
end
