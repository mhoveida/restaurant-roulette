Rails.application.routes.draw do
  get "rooms/new"
  devise_for :users
  get "home/index"
  # root to: "home#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "static_pages#home"
  get "solo_spin", to: "solo_spin#show", as: "solo_spin"
  get 'create_room', to: 'rooms#new', as: 'create_room'
  get 'rooms/:id/join_as_guest', to: 'rooms#join_as_guest', as: 'join_as_guest'

  resources :rooms, only: [:show]
  post 'join_room', to: 'rooms#join'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
