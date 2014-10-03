Rails.application.routes.draw do
  get "/admin" => "ants_admin#index"
  get "/sign_out" => "ants_admin/sessions#destroy"
  
  scope "ants_admin" do  
    get "/admin" => "ants_admin#index"
  end
  
end