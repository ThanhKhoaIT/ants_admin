Rails.application.routes.draw do
  get "/admin" => "ants_admin#index"
  
  scope "admin" do
    get   "/sign_in"    => "ants_admin/sessions#new"
    post  "/sign_in"    => "ants_admin/sessions#create"
    get   "/sign_out"   => "ants_admin/sessions#destroy"
  end
end