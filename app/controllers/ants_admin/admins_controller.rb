class AntsAdmin::AdminsController < AntsAdminController
  def all_default_case
    url = params[:url]
    begin
      urls = url.split("/")
      @model_string = urls[0].singularize
      @model_url = @model_string.pluralize
      begin
        @model_class = @model_string.classify.constantize
      rescue
        return redirect_to "/#{AntsAdmin.admin_path}/errors/not_model?model=#{@model_string}"
      end
      @model_config = AntsAdmin::ModelConfigHelper.new(@model_class)
      
      @params_include = detect_params_include
      
      params[:controller] = @model_string.pluralize
      return redirect_to "/#{AntsAdmin.admin_path}/errors/not_apply?model=#{@model_string}" if !@model_config.apply_admin?
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
        return urls[2] == 'edit' ? edit(urls[1]) : modify_link(urls[1], urls[2]) if request.get?
        return active(urls[1]) if request.post? and urls[2] == 'active'
        return update_belongs_to(urls[1]) if request.post? and urls[2] == 'select'
      end
    rescue => e
      raise e
    end
  end
 
  def index
    params[:action] = "index"
    layout_index_style = @model_config.layout_index_style
    @objects = load_data if layout_index_style == "library"
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
      @objects = load_data.includes(includes).where(like_string.join(" or "))
    else
      @objects = load_data.includes(includes)
    end
    
    sorts.each do |s, index|
      @objects = @objects.order(sorts[s].to_i > 0 ? "#{s} desc" : "#{s} asc")
    end
    
    records = @objects[perPage*(page-1)..perPage*page].collect{|record| @model_config.as_json(record).merge!(@model_config.actions_link.length > 0 ? {actions: actions_link(record)} : {})}
    render json: {records: records, queryRecordCount: @objects.count, totalRecordCount: @objects.count}
  end
  
  def select_box
    all = load_select_box.collect{|item| {
            id: item.id,
            text: represent_text(item)
          }}
    all = all.sort_by {|item| item[:text]}
    
    render json: {all: all}
  end

  def new
    params[:action] = "new"
    if @model_config.create_disabled?
      return render :text => "Create function is disabled!"
    else
      @object = @model_class.new
      load_config_for_form
      render template: "/ants_admin/new"
    end
  end
  
  def add
    params[:action] = "add"
    if @model_config.create_disabled?
      return render :text => "Create function is disabled!"
    else
      @object = @model_class.new
      load_config_for_form
      render template: "/ants_admin/add", layout: false
    end
  end
  
  def create
    params[:action] = "create"
    
    params_add_form = {}
    params.each do |param_name, param_value|
      params_add_form[param_name] = param_value if param_name[-3..-1] == "_id"
    end
    
    if @model_config.create_disabled?
      return render :text => "Create function is disabled!"
    else
      @object = @model_class.new(params_permit)
      if @object.save
        flash[:id] = @object.id
        flash[:notice] = "Create is successful!"
        redirect_to "/#{AntsAdmin.admin_path}/#{@model_class.to_s.tableize}?#{params_add_form.to_query}"
      else
        render template: "/ants_admin/new"
      end
    end
  end
  
  def modify_link(id, action)
    params[:action] = action
    params[:id] = id
    begin
      render template: "/ants_admin/#{@model_string.pluralize}/#{action}"
    rescue Exception => exc
      if exc.to_s.index('Missing template')
        render template: "/ants_admin/modify_link"
      else
        raise exc
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
      load_config_for_form
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
      return render json: {
        success: true,
        actived: @object.active
      } if @object.save
      
      return render json: {
        success: false,
        actived: @object.active
      }
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
        redirect_to "/#{AntsAdmin.admin_path}/#{@model_string.tableize}"
      else
        render template: "/ants_admin/edit"
      end
    end
  end
  
  def update_belongs_to(id)
    params[:action] = "update_belongs_to"
    params[:id] = id
    if @model_config.edit_disabled?
      return render json: {
        success: false,
        messages: "Edit function is disabled!"
      }
    else
      @object = @model_class.find id
      @object["#{params[:type]}_id"] = params[:value]
      if @object.save
        render json: {
          success: true,
          messages: "Update is successful!"
        }
      else
        render json: {
          success: false,
          messages: "Update is failed!"
        }
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
      redirect_to "/#{AntsAdmin.admin_path}/#{@model_string}?#{@params_add_form.to_query}"
    end
  end
  
  def load_data
    @model_class.load_all(@current_user, params) rescue @model_class.load_all(@current_user) rescue @model_class.load_all rescue @model_class.all
  end
  
  def load_select_box
    @model_class.load_select_box(@current_user, params) rescue @model_class.load_select_box(@current_user) rescue @model_class.load_select_box rescue @model_class.all
  end
  
  private
  def load_config_for_form
		form_input_config = @model_config.form_input
		if form_input_config.present?
			columns_show = []
			@object.class.columns.each do |column|
				index = form_input_config.index(column.name)
				index = form_input_config.index(column.name[0..-11]) if !index and column.name[-10..-1] == '_file_name'
				columns_show[index] = column if index
			end
			@columns_show = columns_show.select{|col| col.present?}
		else
			@columns_show = @object.class.columns
		end
		@form_text = AntsAdmin::FormHelper.text_for_form(@model_string) || {}
  end

  
  def params_permit
    params.require(@model_string).permit!
  end
  
  def detect_params_include
    @params_add_form = {}
    params.each do |param_name, param_value|
      @params_add_form[param_name] = param_value if param_name[-3..-1] == "_id"
    end
    @params_add_form.to_query
  end

end
