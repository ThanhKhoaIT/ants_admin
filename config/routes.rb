Rails.application.routes.draw do
  get "/#{AntsAdmin.admin_path}" => "ants_admin#dashboard"
  
  # scope "admin" do
#     get   "/sign_in"    => "ants_admin/sessions#new"
#     post  "/sign_in"    => "ants_admin/sessions#create"
#     get   "/sign_out"   => "ants_admin/sessions#destroy"
#
#     get   "/sign_up"    => "ants_admin/registrations#new"
#     post  "/sign_up"    => "ants_admin/registrations#create"
#   end
  
  
  post 'ants_admin/libraries' => "ants_admin#upload_photo"
  get 'ants_admin/libraries' => "ants_admin#upload_photo_all"
  delete 'ants_admin/libraries' => "ants_admin#upload_photo_destroy"
  
  get "/#{AntsAdmin.admin_path}/errors/:code" => "ants_admin#errors"
  delete "/#{AntsAdmin.admin_path}/errors/:code" => "ants_admin#errors"
  
  # index, new, create, show, edit, update, destroy, search,...
  get "/#{AntsAdmin.admin_path}/*url" => "ants_admin/admins#all_default_case"
  post "/#{AntsAdmin.admin_path}/*url" => "ants_admin/admins#all_default_case"
  patch "/#{AntsAdmin.admin_path}/*url" => "ants_admin/admins#all_default_case"
  delete "/#{AntsAdmin.admin_path}/*url" => "ants_admin/admins#all_default_case"
  
end