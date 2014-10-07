class AntsAdmin::AdminsController < AntsAdminController
  
  def all_default_case
    url = params[:url]
    begin
      urls = url.split("/")
      if url.match(/[a-z_]+$/) and request.get?
        @model_class = urls[0].classify.constantize
        return index if @model_class.included_modules.include?(AntsAdmin::SmartModel)
        raise ActionController::RoutingError.new("No route matches [#{request.method.upcase}] \"/#{url}\"")
      elsif url.match(/[a-z_]+\/new$/) and request.get?
        @model_class = urls[0].classify.constantize
        return new if @model_class.included_modules.include?(AntsAdmin::SmartModel)
        raise ActionController::RoutingError.new("No route matches [#{request.method.upcase}] \"/#{url}\"")
      elsif url.match(/[a-z_]+$/) and request.post?
        @model_class = urls[0].classify.constantize
        return create if @model_class.included_modules.include?(AntsAdmin::SmartModel)
        raise ActionController::RoutingError.new("No route matches [#{request.method.upcase}] \"/#{url}\"")
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
      @object = @model_class.new(params[@model_class.to_s.downcase])
      if @object.save
        redirect_to "/admin/#{@model_class.to_s.downcase}/"
      else
        render template: "/ants_admin/new"
      end
    else
      return render :json => {success: false, messages: "Create function is disabled!"}
    end
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
