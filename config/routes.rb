require 'ruby_event_store/browser/app'

Rails.application.routes.draw do
  root to: 'orders#index'
  resources :orders, only: [:index, :show, :new, :create, :destroy] do
    get  :pay
    post :ship
  end
  resources :payments, only: [:create]

  resources :customers, only: [:index, :show, :new, :edit, :create, :update]
  resources :products

  mount RubyEventStore::Browser::App => '/res' if Rails.env.development?
end
