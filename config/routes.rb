Rails.application.routes.draw do
  get "/admin" => "ants_admin#dashboard"
  
  # scope "admin" do
#     get   "/sign_in"    => "ants_admin/sessions#new"
#     post  "/sign_in"    => "ants_admin/sessions#create"
#     get   "/sign_out"   => "ants_admin/sessions#destroy"
#
#     get   "/sign_up"    => "ants_admin/registrations#new"
#     post  "/sign_up"    => "ants_admin/registrations#create"
#   end
  
  get '/admin/errors/:code'   => "ants_admin#errors"
  
  # index, new, create, show, edit, update, destroy, search,...
  get '/admin/*url'   => "ants_admin/admins#all_default_case"
  post '/admin/*url'   => "ants_admin/admins#all_default_case"
  patch '/admin/*url'   => "ants_admin/admins#all_default_case"
  delete '/admin/*url'   => "ants_admin/admins#all_default_case"
  
end