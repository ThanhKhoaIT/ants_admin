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
    if params[:code] == 'not_apply' and AntsAdmin::ModelConfigHelper.new(params[:model].singularize).apply_admin?
      redirect_to ['',AntsAdmin.admin_path, params[:model].pluralize].join('/')
    else
      render layout: "ants_admin_blank"
    end
  end
  
  def upload_photo_all
    render json: {files: upload_photo_json(AntsAdminLibrary.all)}
  end
  
  def upload_photo
    ids = []
    params[:files].each do |file|
      photo = AntsAdminLibrary.new({
        title: file.original_filename,
        photo: file
      })
      if photo.save
        ids << photo.id
      else
        return render json: {success: false, error: photo.errors}, status: 422
      end
    end
    render json: {success: true, files: upload_photo_json(AntsAdminLibrary.all), ids_uploaded: ids}
  end
  
  def upload_photo_destroy
    file = AntsAdminLibrary.find params[:id]
    if file.destroy
      render json: {files: upload_photo_json(AntsAdminLibrary.all)}
    else
      render json: {success: false}, status: 422
    end
  end
  
  protected
  
  def upload_photo_json(all)
    all.collect do |file|
      {
        id: file.id,
        title: file.title,
        created_at: file.created_at.strftime("%d/%m/%Y"),
        content_type: file.photo_content_type,
        file_size: file.photo_file_size,
        medium: file.photo.url(:medium),
        thumb: file.photo.url(:thumb),
        url: file.photo.url
      }
    end
  end
  
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