Rails.application.routes.draw do
  get "/admin" => "ants_admin#index"
  
  scope "admin" do
    get   "/sign_in"    => "ants_admin/sessions#new"
    post  "/sign_in"    => "ants_admin/sessions#create"
    get   "/sign_out"   => "ants_admin/sessions#destroy"
  end
  
  # index, new, create, show, edit, update, destroy, search,...
  get '/admin/*url'   => "ants_admin/admins#all_default_case"
  post '/admin/*url'   => "ants_admin/admins#all_default_case"
  
end