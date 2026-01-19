Rails.application.routes.draw do
  get "family_group_memberships/edit"
  get "family_group_memberships/update"
  root "home#index"

  # Static Pages
  get '/about',       to: 'pages#about'
  get '/terms',       to: 'pages#terms'
  get '/privacy',     to: 'pages#privacy'
  get '/how_to_use',  to: 'pages#how_to_use'
  get "/faq",     to: "pages#faq"
  get "/contact", to: "pages#contact"
  get "mypage", to: "mypages#show"
  get "users/:id", to: "mypages#show", as: :user

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
  resources :family_group_memberships, only: [:edit, :update]
  resources :posts, only: %i[new create edit update destroy] do
    collection do
      post :prepare_uploads
      post :save_draft
      post :discard_draft
      get  :select_photos
    end
  end

  # 設定画面
  get "family_settings", to: "family_groups#settings"

  # グループの設定（admin/member edit用）
  namespace :family_settings do
    # グループ切り替え
    post "switch", to: "family_groups#switch", as: :switch_family_group
    # 一般ユーザー：家族一覧編集
    get  "members/edit", to: "members#edit"
    delete "members/leave", to: "members#leave", as: :leave_family_group
    # 管理者用：メンバー管理
    resources "admin_members", only: %i[index edit update destroy], path: "members/admin"
    # 管理者用：グループ管理
    resource :group, only: %i[edit update destroy], path: "group"
  end

  # 招待リンク
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
