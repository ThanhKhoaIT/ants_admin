Rails.application.routes.draw do
  get "/admin" => "ants_admin#index"
  
  scope "ants_admin" do  
    get "/admin" => "ants_admin#index"
  end  
end