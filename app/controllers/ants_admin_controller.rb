class AntsAdminController < ApplicationController
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include AntsAdmin::FormHelper
  include AntsAdmin::PageHelper
  include AntsAdmin::IndexHelper
  include AntsAdmin::ModelConfigHelper
  
  before_action :initialize_ants_admin_controller
  before_action :security_controller, except: [:errors]
  # before_action :after_signed!, only: :dashboard
#   before_action :before_signed!
  
  def dashboard
  end
  
  def errors
    render layout: "ants_admin_blank"
  end

  protected

  def initialize_ants_admin_controller
    @current_user = defined?(current_logined) ? current_logined : nil
    @sign_out_link = defined?(sign_out_link) ? sign_out_link : "/admin/errors/not_config_sign_out_link"
    @main_menu =  defined?(ants_admin_main_menu) ? ants_admin_main_menu : [{'text'=> 'Dashboard',
       'active'=> "ants_admin#dashboard",
       "icon"=>"dashboard",
       "url"=>"/admin"}]
    @is_signed = @current_user.present?
  end

  def security_controller
    current_logined if defined?(current_logined)
    redirect_to "/admin/errors/not_config_current_logined" if !@is_signed
  end

  # def after_signed!
  #   if !@is_signed
  #     redirect_to "/admin/sign_in"
  #   end
  # end
  #
  # def before_signed!
  # end

end