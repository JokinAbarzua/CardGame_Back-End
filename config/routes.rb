Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :users
  resources :games
  post "game/join", to: "games#join"
  post "game/deal", to: "games#deal"
  post "game/play", to: "games#play"
  post "game/add_point", to: "games#add_point"
  post "game/remove_point", to: "games#remove_point"
  get "game/status", to: "games#status"
  post "/auth/login", to: "authentication#login"
  post "rails/active_storage/direct_uploads", to: "direct_uploads#create"
end
