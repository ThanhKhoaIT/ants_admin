class AntsAdmin::AdminsController < AntsAdminController
  def all_default_case
    url = params[:url]
    begin
      urls = url.split("/")
      @model_string = urls[0]
      @model_class = @model_string.classify.constantize
      @model_config = AntsAdmin::ModelConfigHelper.new(@model_class)
      params[:controller] = @model_string
      return raise ActionController::RoutingError.new("No route matches [#{request.method.upcase}] \"/#{url}\"") if  !@model_config.apply_admin?
      if urls.count == 1
        return index if request.get?
        return create if request.post?
      elsif urls.count == 2
        respond_to do |format|
          format.json {
            return json if request.get? and urls[1] == 'all'
            return select_box if request.get? and urls[1] == 'select_box'
          }
          format.html {
            return new if request.get? and urls[1] == 'new'
            return update(urls[1]) if request.patch?
            return delete(urls[1]) if request.delete?
            return add if request.get? and urls[1] == 'add'
          }
        end
      elsif urls.count == 3
        return edit(urls[1]) if request.get? and urls[2] == 'edit'
        return active(urls[1]) if request.post? and urls[2] == 'active'
        return update_belongs_to(urls[1]) if request.post? and urls[2] == 'select'
      end
    rescue => e
      raise e
    end
  end
 
  def index
    layout_index_style = @model_config.layout_index_style
    params[:action] = "index"
    render template: "/ants_admin/index_styles/#{layout_index_style}"
  end
  
  def json
    params[:action] = "json"
    page = (params[:page] || 1).to_i
    page = page > 0 ? page : 1
    perPage = (params[:perPage] || 10).to_i
    perPage = perPage > 0 ? perPage : 1
    search = params[:queries] ? params[:queries][:search] : nil
    sorts = params[:sorts] || []
    
    includes = (@model_config.has_many_list + @model_config.belongs_to_list).collect{|i|i[:label].downcase}
    
    if search
      like_string = []
      @model_config.search_for.each do |attr, index|
        like_string << "#{attr} like '%#{search}%'"
      end
      @objects = @model_class.includes(includes).where(like_string.join(" or "))
    else
      @objects = @model_class.includes(includes).all
    end
    
    sorts.each do |a, index|
      @objects = @objects.order(sorts[a].to_i > 0 ? "#{a} desc" : "#{a} asc")
    end
    
    records = @objects[perPage*(page-1)..perPage*page].collect{|record| @model_config.as_json(record).merge!(@model_config.actions_link.length > 0 ? {actions: actions_link(record)} : {})}
    render json: {records: records, queryRecordCount: @objects.count, totalRecordCount: @objects.count}
  end
  
  def select_box
    if defined?(@model_class.select_box)
      all = @model_class.select_box(params) rescue @model_class.select_box
    else
      all = @model_class.all.collect{|item| {
              id: item.id,
              text: represent_text(item)
            }}
      all = all.sort_by {|item| item[:text]}
    end
    
    render json: {all: all}
  end

  def new
    params[:action] = "new"
    if @model_config.create_disabled?
      return render :text => "Create function is disabled!"
    else
      @object = @model_class.new
      render template: "/ants_admin/new"
    end
  end
  
  def add
    params[:action] = "add"
    if @model_config.create_disabled?
      return render :text => "Create function is disabled!"
    else
      @object = @model_class.new
      render template: "/ants_admin/add", layout: false
    end
  end
  
  def create
    params[:action] = "create"
    if @model_config.create_disabled?
      return render :text => "Create function is disabled!"
    else
      @object = @model_class.new(params_permit)
      if @object.save
        flash[:id] = @object.id
        flash[:notice] = "Create is successful!"
        redirect_to "/admin/#{@model_class.to_s.downcase}"
      else
        render template: "/ants_admin/new"
      end
    end
  end
  
  def edit(id)
    params[:action] = "edit"
    params[:id] = id
    if @model_config.edit_disabled?
      return render :text => "Edit function is disabled!"
    else
      @object = @model_class.find id
      render template: "/ants_admin/edit"
    end
  end
  
  def active(id)
    params[:action] = "active"
    params[:id] = id
    @object = @model_class.find id
    if defined?(@object.active).nil?
      return render :text => "Active function is not found!"
    else
      @object.active = !@object.active.present?
      return render json: {success: true, actived: @object.active} if @object.save
      return render json: {success: false, actived: @object.active}
    end
  end
  
  def update(id)
    params[:action] = "update"
    params[:id] = id
    if @model_config.edit_disabled?
      return render :text => "Edit function is disabled!"
    else
      @object = @model_class.find id
      if @object.update(params_permit)
        flash[:id] = id
        flash[:notice] = "Update is successful!"
        redirect_to "/admin/#{@model_string}"
      else
        render template: "/ants_admin/edit"
      end
    end
  end
  
  def update_belongs_to(id)
    params[:action] = "update_belongs_to"
    params[:id] = id
    if @model_config.edit_disabled?
      return render json: {success: false, messages: "Edit function is disabled!"} 
    else
      @object = @model_class.find id
      @object["#{params[:type]}_id"] = params[:value]
      if @object.save
        render json: {success: true, messages: "Update is successful!"}
      else
        render json: {success: false, messages: "Update is failed!"}
      end
    end
  end
  
  def delete(id)
    params[:action] = "delete"
    params[:id] = id
    if @model_config.delete_disabled?
      return render :text => "Edit function is disabled!"
    else
      @object = @model_class.find id
      if @object
        @object.destroy
        flash[:notice] = "#{@model_string} is removed!"
      end
      redirect_to "/admin/#{@model_string}"
    end
  end
  
  private
  def params_permit
    params.require(@model_string).permit!
  end
end
