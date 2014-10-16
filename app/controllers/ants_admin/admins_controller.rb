class AntsAdmin::AdminsController < AntsAdminController
  before_action :get_current_user
  before_action :after_signed!
  
  def all_default_case
    url = params[:url]
    begin
      urls = url.split("/")
      @model_string = urls[0]
      @model_class = @model_string.classify.constantize
      params[:controller] = @model_string
      return raise ActionController::RoutingError.new("No route matches [#{request.method.upcase}] \"/#{url}\"") if !@model_class.included_modules.include?(AntsAdmin::SmartModel)
      if urls.count == 1
        return index if request.get?
        return create if request.post?
      elsif urls.count == 2
        respond_to do |format|
          format.json {return json if request.get? and urls[1] == 'all'}
        end
        return new if request.get? and urls[1] == 'new'
      elsif urls.count == 3
        return edit if request.get? and urls[2] == 'edit'
      end
    rescue => e
      raise e
    end
  end
 
  def index
    params[:action] = "index"
    @objects = @model_class.all
    render template: "/ants_admin/index"
  end
  
  def json
    params[:action] = "json"
    @objects = @model_class.all
    render json: {data: @objects}
  end

  
  def new
    params[:action] = "new"
    if not_create_disabled
      @object = @model_class.new
      render template: "/ants_admin/new"
    else
      return render :json => {success: false, messages: "Create function is disabled!"}
    end
  end
  
  def create
    params[:action] = "create"
    if not_create_disabled
      @object = @model_class.new(params_permit)
      if @object.save
        redirect_to "/admin/#{@model_class.to_s.downcase}/"
      else
        render template: "/ants_admin/new"
      end
    else
      return render :json => {success: false, messages: "Create function is disabled!"}
    end
  end
  
  private
  def params_permit
    params.require(@model_string).permit!
  end
    
  protected
  
  def not_create_disabled
    defined?(@model_class::CREATE_DISABLED).nil? or !@model_class::CREATE_DISABLED
  end
  
  #
  # # POST /admin/sign_in
  # def create
  #  @token = resource_name.constantize.login_with(params[resource_name][:login], params[resource_name][:password])
  #  if @token
  #    cookies[:token] = @token
  #    redirect_to '/admin'
  #  else
  #    redirect_to '/admin/sign_in'
  #  end
  # end
  #
  # # DELETE /admin/sign_out
  # def destroy
  #   cookies[:token] = nil
  #   redirect_to '/admin/sign_in'
  # end
end
