require "sidekiq/web"

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(username, ENV.fetch("SIDEKIQ_USERNAME", "admin")) &
  ActiveSupport::SecurityUtils.secure_compare(password, ENV.fetch("SIDEKIQ_PASSWORD", "password"))
end

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  mount Sidekiq::Web => "/sidekiq"

  # ActionCable for real-time updates
  mount ActionCable.server => "/cable"

  root "profiles#index"

  resources :profiles do
    member do
      post :rescan
      get :status
    end
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :profiles, only: [ :index, :show ]
    end
  end

  # Error pages
  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all
end
