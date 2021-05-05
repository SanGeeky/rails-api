# config/routes.rb
Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  resources :todos do
    resources :items
  end
end
