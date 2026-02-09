require "sidekiq/web"

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  if Rails.env.development?
    mount Sidekiq::Web => "/sidekiq"
  end

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
