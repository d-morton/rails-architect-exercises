Rails.application.routes.draw do
  root to: 'orders#index'
  resources :orders, only: [:index, :new, :create, :destroy]
  resources :products
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
