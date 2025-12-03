Rails.application.routes.draw do
  get "children/new"
  get "children/create"
  get "family_settings", to: "family_groups#settings"
  get "family_groups/update"
  get "posts/new"
  get "albums/index"
  get "sessions/callback"
  get "sessions/destroy"
  get "posts/new", to: "posts#new", as: :new_post
  get "invite/:token", to: "invite_tokens#show", as: :invite
  root "home#index"

  resources :albums, only: [:index, :show, :new, :create]
  resources :family_groups, only: [:new, :create, :edit, :update]
  resources :children, only: [:new, :create]
  resources :posts, only: [:new, :create, :show]
  resources :invite_tokens, only: [:create]

  # 仮リンク用（あとで本実装予定）
  get 'about', to: 'home#about'
  get 'login', to: 'home#login'

  # LINEログイン
  get "login/line", to: redirect("/auth/line"), as: :line_login
  get "/auth/:provider/callback", to: "sessions#create"
  # ログアウト
  delete "logout", to: "sessions#destroy", as: :logout

  # ヘルスチェックとPWA用
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  if Rails.env.test?
    post 'test/login', to: 'test_sessions#create'
  end

  # 開発環境用のログイン簡略化ルート
  if Rails.env.development?
    get "/dev_login/:id", to: "sessions#dev_login"
  end
end
