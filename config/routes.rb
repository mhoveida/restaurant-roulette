Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  root "static_pages#home"

  # Solo Spin
  get "solo_spin", to: "solo_spin#show", as: "solo_spin"
  post "solo_spin", to: "solo_spin#spin"
  post "solo_spin/save_to_history", to: "solo_spin#save_to_history", as: "save_to_history"

  # Room Creation
  get "create_room", to: "rooms#new", as: "create_room"

  # Guest Joining
  get "rooms/:id/join_as_guest", to: "rooms#join_as_guest", as: "join_as_guest"
  post "rooms/:id/join_as_guest", to: "rooms#join_as_guest"

  # Room Resources
  resources :rooms, only: [ :show, :create ] do
    member do
      # Spinning Phase
      post :start_spinning
      post :spin

      # Reveal Phase
      post :reveal

      # Voting Phase
      post :vote
      post :confirm_vote

      # Additional Rounds
      post :new_round

      # Real-time Status
      get :status
    end
  end

  # Join Room
  post "join_room", to: "rooms#join"

  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check

  get "neighborhoods", to: "rooms#neighborhoods"
  get "cuisines", to: "rooms#cuisines"
  get "dietary_restrictions", to: "rooms#dietary_restrictions"

  # User History
  get "user_history", to: "user_histories#show", as: "user_history"
  delete "user_history/:restaurant_id", to: "user_histories#destroy", as: "remove_from_history"

  # Devise OAuth Failure
  devise_scope :user do
    get "/users/auth/failure", to: "users/omniauth_callbacks#failure"
  end
end
