Rails.application.routes.draw do
  # Authentication
  resource :session, only: [ :new, :create, :destroy ]
  resource :registration, only: [ :new, :create ]

  # Domain resources
  resources :patients
  resources :practitioners
  resources :appointments do
    collection do
      get :calendar
    end
  end
  resources :medical_records
  resources :invoices do
    member do
      patch :mark_paid
    end
  end

  # Reports
  resources :reports, only: [ :index ] do
    collection do
      get :financial
      get :export
    end
  end

  # Root path
  root "dashboard#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
