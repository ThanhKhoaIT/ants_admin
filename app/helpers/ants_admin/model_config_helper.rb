module AntsAdmin
  module ModelConfigHelper
        
    def self.new(model_string)
      @model_string = model_string
      self
    end
    
    # LIST
    def self.table_show
      titles = defined?(@model_string::TABLE_SHOW) ? @model_string::TABLE_SHOW : @model_string.new.attributes.select{|attr_name, value| !(["created_at","updated_at","active"]).include?(attr_name) and attr_name[-3,3] != "_id"}.collect{|attr_name, value| attr_name}
      titles += belongs_to_list + has_many_list
      titles = titles.collect{|title| title.is_a?(Hash) ? {sort:true}.merge(title) : {
        key: title,
        label: [title.slice(0, 1).capitalize, title.slice(1..-1)].join(),
        sort: true
      }}
      titles.uniq!{|t| t[:key]}
      titles = titles.select{|title| !table_show_skip.include?(title[:label])}
      return titles
    end
    
    def self.table_show_skip
      config_list = []
      config_list = @model_string::TABLE_SHOW_SKIP if defined?(@model_string::TABLE_SHOW_SKIP)
      return [config_list] if !config_list.is_a?(Array)
      return config_list
    end
    
    def self.form_input_skip
      config_list = []
      config_list = @model_string::FORM_INPUT_SKIP if defined?(@model_string::FORM_INPUT_SKIP)
      return [config_list] if !config_list.is_a?(Array)
      return config_list
    end
    
    def self.search_for
      defined?(@model_string::SEARCH_FOR) ? @model_string::SEARCH_FOR : []
    end
    
    def self.actions_link
      defaults = ['edit','active','remove']
      if defined?(@model_string::ACTIONS_LINK)
        return [] if @model_string::ACTIONS_LINK.is_a?(FalseClass)
        actions = @model_string::ACTIONS_LINK.is_a?(TrueClass) ? defaults : @model_string::ACTIONS_LINK
      else
        actions = defaults
      end
      actions = [actions]     if !actions.is_a?(Array)
      actions -= ['edit']     if edit_disabled?
      actions -= ['active']   if active_disabled?
      actions -= ['remove']   if delete_disabled?
      return actions
    end
    
    def self.belongs_to_list
      list = []
      @model_string.reflections.select do |assoc_name, ref|
        list << {
          key: "#{assoc_name.to_s}_id",
          label: [assoc_name.to_s.slice(0, 1).capitalize, assoc_name.to_s.slice(1..-1)].join(),
          sort: true
        } if ref.macro.to_s == "belongs_to"
      end
      return list
    end
       
    def self.has_many_list
      list = []
      @model_string.reflections.select do |assoc_name, ref|
        list << {
          key: "#{assoc_name.to_s}_id",
          label: [assoc_name.to_s.slice(0, 1).capitalize, assoc_name.to_s.slice(1..-1)].join(),
          sort: true
        } if ref.macro.to_s == "has_many"
      end
      return list
    end
    
    # YES - NO
    
    def self.apply_admin?
      defined?(@model_string::APPLY_ADMIN) and @model_string::APPLY_ADMIN
    end
    
    def self.create_disabled?
      defined?(@model_string::CREATE_DISABLED) and @model_string::CREATE_DISABLED
    end

    def self.delete_disabled?
      defined?(@model_string::DELETE_DISABLED) and @model_string::DELETE_DISABLED
    end

    def self.edit_disabled?
      defined?(@model_string::EDIT_DISABLED) and @model_string::EDIT_DISABLED
    end
    
    def self.active_disabled?
      (defined?(@model_string::ACTIVE_DISABLED) and @model_string::ACTIVE_DISABLED) or defined?(@model_string.new.active).nil?
    end
    
    # TEXT
    def self.title
      defined?(@model_string::TITLE) ? @model_string::TITLE : @model_string.to_s
    end

    # HASH
    
    def self.as_json(obj)
      hash = {}
      table_show.each do |title|
        key = title[:key]
        value = title[:label]
        add_update_tool = false
        
        if key[-3,3] != "_id"
          hash[key] = self.json_with_file(obj, key) rescue attribute_show(obj, key)
        else
          add_update_tool = true
          hash[key] = obj.send(value.downcase)
        end
        
        if hash[key].class.to_s.index("ActiveRecord_Associations_CollectionProxy")
          add_update_tool = false
          list = []
          hash[key].each do |item|
            text = defined?(item.represent_text) ? item.represent_text : item.to_s
            model_string = item.class.name.downcase
            list << "<li><a href='/admin/#{model_string}/#{item.id}/edit' back-href='/admin/#{obj.class.name.downcase}' back-level='2'>#{text}</a></li>"
          end
          hash[key] = html_show_list_with_has_many(list)
        else
          hash[key] = hash[key].to_s
        end
        if add_update_tool
          hash[key] = ["<div class='select_edit'>","<span>#{hash[key]}</span>","<a class='fa fa-cog' href='#'></a>","<data type='#{key[0..-4]}' value='#{obj.send(value.downcase).id}' obj-id='#{obj.id}' model='#{obj.class.name.downcase}'/>","</div>"].join
        end
      end
      return hash
    end

    # Skins
    
    ## Buttons HTML
    
    def self.html_button_delete
      (defined?(@model_string::HTML_BUTTON_DELETE) ? @model_string::HTML_BUTTON_DELETE : '<i class="fa fa-trash-o"></i>').html_safe
    end
    
    def self.html_button_edit
      (defined?(@model_string::HTML_BUTTON_EDIT) ? @model_string::HTML_BUTTON_EDIT : '<i class="fa fa-pencil-square-o"></i>').html_safe
    end
    
    def self.html_button_activated
      (defined?(@model_string::HTML_BUTTON_ACTIVATED) ? @model_string::HTML_BUTTON_ACTIVATED : '<i class="fa fa-unlock"></i>').html_safe
    end
    
    def self.html_button_deactivated
      (defined?(@model_string::HTML_BUTTON_DEACTIVATED) ? @model_string::HTML_BUTTON_DEACTIVATED : '<i class="fa fa-lock"></i>').html_safe
    end
    
    private
    
    def self.html_show_list_with_has_many(list)
      html = list.length > 0 ? "<a class='fa fa-list show-btn-list btn btn-sm btn-default' href='#'></a><ul class='btn-list'>#{list.join}<a class='close_list fa fa-times'></a></ul>" : ""
    end
    
    def self.json_with_file(obj, key)
      type = obj.send("#{key}_content_type")
      url = obj.send(key).url
      file_name = obj.send("#{key}_file_name")
      file_types = {
        'image/jpeg'=> 'image',
        'image/png'=> 'image',
        'application/pdf'=> 'file-pdf-o',
        'text/plain'=> 'file-text',
        'text/csv'=> 'file-text-o',
        'application/msword'=> 'file-word-o',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document'=> 'file-word-o',
        'application/vnd.ms-excel'=> 'file-excel-o',
        'application/vnd.ms-powerpoint'=> 'file-powerpoint-o',
        'application/zip'=> 'file-zip-o',
        'application/x-rar-compressed'=> 'file-zip-o',
        'application/x-photoshop'=> 'file-photo-o'
      }
      icon = file_types[type] || 'paperclip'
      return  type ? (icon == 'image' ? "<img src='#{url}' class='cover file' title='#{file_name}'/>" : "<a href='#{obj.send("#{key}").url}' target='_blank' class='btn btn-default file fa fa-#{icon}' title='#{file_name}'></a>") : ""
    end
    
    def self.attribute_show(obj, attr_name)
      return obj.send("#{attr_name}_show") rescue obj.send(attr_name)
    end

  end
end