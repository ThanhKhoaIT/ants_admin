class AntsAdminController < ApplicationController
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include AntsAdmin::FormHelper
  include AntsAdmin::PageHelper
  include AntsAdmin::IndexHelper
  include AntsAdmin::ModelConfigHelper
  
  before_action :initialize_ants_admin_controller
  before_action :security_controller, except: [:errors]

  def dashboard
    ants_admin_dashboard if defined?(ants_admin_dashboard)
  end
  
  def errors
    render layout: "ants_admin_blank"
  end

  protected

  def initialize_ants_admin_controller
    @current_user = defined?(current_logined) ? current_logined : nil
    @sign_out_link = defined?(sign_out_link) ? sign_out_link : "/#{AntsAdmin.admin_path}/errors/not_config_sign_out_link"
    @main_menu =  defined?(ants_admin_main_menu) ? ants_admin_main_menu : [{'text'=> 'Dashboard',
       'active'=> "ants_admin#dashboard",
       "icon"=>"dashboard",
       "url"=>"/#{AntsAdmin.admin_path}"}]
    @is_signed = @current_user.present?
  end

  def security_controller
    current_logined if defined?(current_logined)
    redirect_to "/#{AntsAdmin.admin_path}/errors/not_config_current_logined" if !@is_signed
  end

end