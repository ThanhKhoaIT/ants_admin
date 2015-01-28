require 'rails/generators/named_base'

module AntsAdmin
  module Generators
    class AntsAdminGenerator < Rails::Generators::Base
      include Rails::Generators::ResourceHelpers
      
      namespace "ants_admin"
      source_root File.expand_path("../templates", __FILE__)
      argument :params, type: :array, default: [], banner: "field:type field:type"
      hook_for :orm
      
      def name
        @name = params.present? ? params[0] : "user"
      end
      
      class_option :routes, desc: "Generate routes", type: :boolean, default: true
      
      def add_ants_admin_routes
        route "devise_for :#{@name.pluralize}"
      end
      
      def seed_data
        File.open("db/seeds.rb", "a+"){|f| f << "if !#{@name.classify}.find_by_username('superadmin')
  #{@name.classify}.new({
    username: 'superadmin',
    email: 'thanhkhoait@gmail.com',
    password: 'password',
    first_name: 'Nguyen Thanh',
    last_name: 'Khoa'
  }).save(validate: false)
end
        " }
      end
      
      def append_to_application_controller
        inject_into_file 'app/controllers/application_controller.rb', after: "class ApplicationController < ActionController::Base\n" do

  "before_filter :layout_for_devise
  before_action :devise_parameters, if: :devise_controller?

  def layout_for_devise
    self.class.layout 'devise' if devise_controller?
  end

  def devise_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, :avatar, :username, :first_name, :last_name) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password, :avatar, :first_name, :last_name) }
  end

  def current_logined
    authenticate_#{@name.singularize}!
  end

  def ants_admin_main_menu
    menu = []

    menu << {
      'text'=> 'Dashboard',
      'active'=> 'ants_admin#dashboard',
      'icon'=>'dashboard',
      'url'=>'/admin'
    }
  end"

end
  
      end      
    end
  end
end