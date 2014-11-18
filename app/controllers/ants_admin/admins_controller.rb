class AntsAdmin::AdminsController < AntsAdminController  
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
          format.html {
            return new if request.get? and urls[1] == 'new'
            return update(urls[1]) if request.patch?
            return delete(urls[1]) if request.delete?
          }
        end
      elsif urls.count == 3
        return edit(urls[1]) if request.get? and urls[2] == 'edit'
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
    page = (params[:page] || 1).to_i
    page = page > 0 ? page : 1
    perPage = (params[:perPage] || 1).to_i
    perPage = perPage > 0 ? perPage : 1
    search = params[:queries] ? params[:queries][:search] : nil
    sorts = params[:sorts] || []
    
    if search
      like_string = []
      @model_class::SEARCH_FOR.each do |attr, index|
        like_string << "#{attr} like '%#{search}%'"
      end
      @objects = @model_class.where(like_string.join(" or "))
    else
      @objects = @model_class.all
    end
    
    sorts.each do |a, index|
      @objects = @objects.order(sorts[a].to_i > 0 ? "#{a} desc" : "#{a} asc")
    end
    
    records = @objects[perPage*(page-1)..perPage*page].collect{|record| record.as_json.merge!({actions: defined?(record.actions) ? record.actions : ""})}
    render json: {records: records, queryRecordCount: @objects.count, totalRecordCount: @objects.count}
  end
  
  def new
    params[:action] = "new"
    if not_create_disabled
      @object = @model_class.new
      render template: "/ants_admin/new"
    else
      return render :text => "Create function is disabled!"
    end
  end
  
  def create
    params[:action] = "create"
    if not_create_disabled
      @object = @model_class.new(params_permit)
      if @object.save
        flash[:notice] = "Create is successful!"
        redirect_to "/admin/#{@model_class.to_s.downcase}"
      else
        render template: "/ants_admin/new"
      end
    else
      return render :text => "Create function is disabled!"
    end
  end
  
  def edit(id)
    params[:action] = "edit"
    params[:id] = id
    if not_edit_disabled
      @object = @model_class.find id
      render template: "/ants_admin/edit"
    else
      return render :text => "Edit function is disabled!"
    end
  end
  
  def update(id)
    params[:action] = "update"
    params[:id] = id
    if not_edit_disabled
      @object = @model_class.find id
      if @object.update(params_permit)
        flash[:notice] = "Update is successful!"
        redirect_to "/admin/#{@model_string}"
      else
        render template: "/ants_admin/edit"
      end
    else
      return render :text => "Edit function is disabled!"
    end
  end
  
  def delete(id)
    params[:action] = "delete"
    params[:id] = id
    if not_delete_disabled
      @object = @model_class.find id
      if @object
        @object.destroy
        flash[:notice] = "#{@model_string} is removed!"
      end
      redirect_to "/admin/#{@model_string}"
    else
      return render :text => "Edit function is disabled!"
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
  
  def not_edit_disabled
    defined?(@model_class::EDIT_DISABLED).nil? or !@model_class::EDIT_DISABLED
  end
  
  def not_delete_disabled
    defined?(@model_class::DELETE_DISABLED).nil? or !@model_class::DELETE_DISABLED
  end
end
