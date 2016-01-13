Rails.application.routes.draw do
  get "/#{AntsAdmin.admin_path}" => "ants_admin#dashboard"

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
