class AntsAdminController < ActionController::Base
  
  before_action :authenticate_login, only: :index
  def index
  end
  
  def authenticate_login
    
  end

  helper AntsAdminHelper
  

  protected
end