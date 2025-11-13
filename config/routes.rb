Rails.application.routes.draw do
  root "home#index"

  # 仮リンク用（あとで本実装予定）
  get 'about', to: 'home#about'
  get 'login', to: 'home#login'

  get "up" => "rails/health#show", as: :rails_health_check

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

end
