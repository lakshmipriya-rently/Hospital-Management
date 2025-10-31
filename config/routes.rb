Rails.application.routes.draw do
  use_doorkeeper

  get "surgeries/index"
  get "surgeries/show"
  get "surgeries/new"

  post "/surgeries/:id/edit", to: "surgeries#edit", as: "edit_surgery"

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get "home/index" , to: "home#index"
  get "home/redirect_by_role", to: "home#redirect_by_role"

  devise_for :users, controllers: { registrations: "users/registrations" }

  resources :surgeries, only: [:index, :show, :new, :create, :destroy,:edit,:update] do
    post :book_appointment, on: :member
    resources :appointments, only: [:new, :create, :update]
  end

  resources :appointments 
  resources :patients
  resources :doctors, only: [:index,:show,:edit,:update]
  resources :staffs
  resources :bills
  resources :payments

  namespace :api do
    namespace :v1 do
      resources :appointments, only: [:index,:show,:create,:update]
      resources :users, only: [:index,:show]
      resources :doctors, only: [:index,:show,:update,:edit]
      resources :patients do
        member do 
          get :confirmed
        end
      end
      resources :surgeries, only: [:index, :show, :create, :destroy,:edit,:update] do
        post :book_appointment, on: :member
      end
    end
  end

  authenticated :user do
    root to: "home#redirect_by_role", as: :authenticated_root
  end

  unauthenticated do
    root to: "home#index", as: :unauthenticated_root
  end

resources :patients do
  member do
    get :confirmed
  end
end


  # get "patients/:id/show_patient_appointments"
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
