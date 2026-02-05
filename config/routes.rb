require "sidekiq/web"

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  if Rails.env.development?
    mount Sidekiq::Web => "/sidekiq"
  end

  root "profiles#index"

  resources :profiles do
    member do
      post :rescan
    end
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :profiles, only: [ :index, :show ]
    end
  end
end
