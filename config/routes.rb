Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :users, except: [:update,:destroy]
  put "user", to: "users#update"
  delete "user", to: "users#destroy"
  resources :games
  post "game/join", to: "games#join"
  post "game/deal", to: "games#deal"
  post "game/play", to: "games#play"
  post "game/discard", to: "games#discard"
  post "game/add_point", to: "games#add_point"
  post "game/remove_point", to: "games#remove_point"
  get "game/status", to: "games#status"
  post "game/end", to: "games#end_game"
  post "/auth/login", to: "authentication#login"
  post "/auth/logout", to: "authentication#logout"
  post "rails/active_storage/direct_uploads", to: "direct_uploads#create"
end
