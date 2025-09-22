Rails.application.routes.draw do
  get "home/index"
  get "home/redirect_by_role"

  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  # Authenticated vs unauthenticated roots
  authenticated :user do
    root "home#redirect_by_role", as: :authenticated_root
  end

  unauthenticated do
    root to: redirect("/home/index"), as: :unauthenticated_root
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  resources :doctors
  resources :patients
  resources :staffs
  resources :appointments
  resources :bills
  resources :payments
end
