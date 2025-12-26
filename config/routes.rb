Rails.application.routes.draw do
  root "home#index"

  # Static Pages
  get '/about',       to: 'pages#about'
  get '/terms',       to: 'pages#terms'
  get '/privacy',     to: 'pages#privacy'
  get '/how_to_use',  to: 'pages#how_to_use'

  # LINEログイン
  get "login/line", to: redirect("/auth/line"), as: :line_login
  get "/auth/:provider/callback", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  # メイン機能
  resource :mypage, only: [:show, :edit, :update]
  resources :albums, only: %i[index show new create]
  resources :family_groups, only: %i[new create edit update]
  resources :children, only: %i[new create edit update destroy]
  resources :invite_tokens, only: %i[create]
  resources :posts, only: %i[new create show edit update destroy] do
    collection do
      get :select_photos
      post :confirm_photos
    end
  end

  # 設定画面
  get "family_settings", to: "family_groups#settings"
  get "invite/:token", to: "invite_tokens#show", as: :invite

  # PWA / health
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker"
  get "manifest" => "rails/pwa#manifest"

  if Rails.env.test?
    post 'test/login', to: 'test_sessions#create'
  end

  if Rails.env.development?
    get "/dev_login/:id", to: "sessions#dev_login"
  end
end
