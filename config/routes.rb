Rails.application.routes.draw do
  get "/admin" => "ants_admin#index"
  
  scope "ants_admin" do  
    get "/admin" => "ants_admin#index"
  end
  
  # Authentycation
  get "sign_in" => "ants_admin/sessions#new"
  get "sign_up" => "ants_admin/registrations#new"
  get "password/new", controller: 'ants_admin/passwords', action: :new
  
  
end