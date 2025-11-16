Rails.application.routes.draw do
  get "sessions/callback"
  get "sessions/destroy"
  root "home#index"

  # 仮リンク用（あとで本実装予定）
  get 'about', to: 'home#about'
  get 'login', to: 'home#login'

  # LINEログイン
  get "auth/line", as: :line_login
  get "auth/line/callback", to: "sessions#create"
  # ログアウト
  delete "logout", to: "sessions#destroy", as: :logout

  get "up" => "rails/health#show", as: :rails_health_check

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
