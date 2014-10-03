Rails.application.routes.draw do
  get "/admin" => "ants_admin#index"
  
  scope "admin" do
    get "/sign_in" => "ants_admin/sessions#new"
    get "/sign_out" => "ants_admin/sessions#destroy"
  end
  
  # scope "ants_admin" do
#     get "/admin" => "ants_admin#index"
#   end
  
end