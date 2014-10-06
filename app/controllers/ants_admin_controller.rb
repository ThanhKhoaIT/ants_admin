class AntsAdminController < ActionController::Base
  include AntsAdmin::FormHelper
  before_action :get_current_user
  before_action :after_signed!, only: :index
  before_action :before_signed!
  
  def index
  end

  protected

  def get_current_user
    @is_signed = false
    @current_user = nil
    if cookies[:token]
      @current_user = resource_model.login_token(cookies[:token])
      @is_signed = @current_user.present?
    end
  end

  def after_signed!
    if !@is_signed
      redirect_to "/admin/sign_in"
    end
  end
  
  def before_signed!
  end

end