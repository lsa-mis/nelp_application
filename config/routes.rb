Rails.application.routes.draw do
  root to: 'static_pages#home'

  # Devise routes
  devise_for :users
  devise_for :admin_users, ActiveAdmin::Devise.config

  # ActiveAdmin routes
  ActiveAdmin.routes(self)

  # Static pages
  get '/about',   to: 'static_pages#about'
  get '/privacy', to: 'static_pages#privacy'
  get '/terms',   to: 'static_pages#terms'

  # Payment routes
  get  'payment_receipt', to: 'payments#payment_receipt'
  post 'payment_receipt', to: 'payments#payment_receipt'
  get  '/payment_show',   to: 'payments#payment_show', as: 'all_payments'
  get  'make_payment',    to: 'payments#make_payment'
  post 'make_payment',    to: 'payments#make_payment'

  # Development-only routes
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
end
