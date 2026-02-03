Rails.application.routes.draw do
  # Custom health endpoint with database connectivity check
  get "health" => "health#show"

  resources :invoices, only: [] do
    get :overdue, on: :collection
    post :generate, on: :collection
  end
end
