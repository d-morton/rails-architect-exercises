Rails.application.routes.draw do
  root to: 'orders#index'
  resources :orders, only: [:index, :show, :new, :create, :destroy] do
    get  :pay
    post :ship
  end
  resources :payments, only: [:create]

  resources :customers, only: [:index, :show, :new, :edit, :create, :update]
  resources :products
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
