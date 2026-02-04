Rails.application.routes.draw do
  root 'profiles#index'

  resources :profiles do
    member do
      post :rescan
    end
  end

  namespace :api do
    resources :profiles, only: [:index, :show]
  end
end
