Rails.application.routes.draw do
  scope "ants_admin" do  
    get "/admin" => "ants_admin#index"
  end  
end