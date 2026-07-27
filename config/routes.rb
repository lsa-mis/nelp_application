Rails.application.routes.draw do
  root to: 'static_pages#home'

  # Devise routes
  devise_for :users, controllers: { sessions: 'users/sessions' }
  devise_for :admin_users,
             path: 'admin',
             path_names: { sign_in: 'login', sign_out: 'logout' },
             controllers: {
               sessions: 'admin_users/sessions',
               passwords: 'admin_users/passwords'
             }

  # LSA TDX Feedback routes
  mount LsaTdxFeedback::Engine => '/lsa_tdx_feedback', as: 'lsa_tdx_feedback'

  namespace :admin do
    root to: 'dashboard#show'
    resources :payments, except: :destroy
    resources :users, only: %i[index show]
    resources :program_settings
    resources :static_pages, only: %i[index edit update]
    resources :admin_users
  end

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
