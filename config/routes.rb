Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users
  root to: 'static_pages#home'
  get '/about', to: 'static_pages#about'
  get '/privacy', to: 'static_pages#privacy'
  get '/terms', to: 'static_pages#terms'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'payments', to: 'payments#index'
  get 'payment_receipt', to: 'payments#payment_receipt'
  post 'payment_receipt', to: 'payments#payment_receipt'
  get '/payment_show', to: 'payments#payment_show', as: 'all_payments'
  get 'make_payment', to: 'payments#make_payment'
  post 'make_payment', to: 'payments#make_payment'
end
