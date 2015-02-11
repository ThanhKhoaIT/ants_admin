module AntsAdmin
  module ModelConfigHelper
        
    def self.new(model_string)
      @model_class = model_string.classify.constantize
      self
    end
    
    # LIST
    def self.table_show
      titles = defined?(@model_class::TABLE_SHOW) ? @model_class::TABLE_SHOW : @model_class.new.attributes.select{|attr_name, value| !(["created_at","updated_at","active"]).include?(attr_name) and attr_name[-3,3] != "_id"}.collect{|attr_name, value| attr_name}
      titles = [titles] if !titles.is_a?(Array)
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
      get_list(@model_class::TABLE_SHOW_SKIP) rescue []
    end
    
    def self.form_input_skip
      get_list(@model_class::FORM_INPUT_SKIP) rescue []
    end
    
    def self.form_input_nested_skip
      get_list(@model_class::FORM_INPUT_NESTED_SKIP) rescue []
    end
    
    def self.form_input
      get_list(@model_class::FORM_INPUT) rescue []
    end
    
    def self.search_for
      get_list(@model_class::SEARCH_FOR) rescue []
    end
    
    def self.actions_link
      defaults = ['edit','active','remove']
      if defined?(@model_class::ACTIONS_LINK)
        return [] if @model_class::ACTIONS_LINK.is_a?(FalseClass)
        actions = @model_class::ACTIONS_LINK.is_a?(TrueClass) ? defaults : @model_class::ACTIONS_LINK
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
      @model_class.reflections.select do |assoc_name, ref|
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
      @model_class.reflections.select do |assoc_name, ref|
        list << {
          key: "#{assoc_name.to_s}_id",
          label: [assoc_name.to_s.pluralize.slice(0, 1).capitalize, assoc_name.to_s.pluralize.slice(1..-1)].join(),
          sort: true
        } if ref.macro.to_s == "has_many"
      end
      return list
    end
    
    def self.textarea_only
      get_list(@model_class::TEXTAREA_ONLY) rescue []
    end
    
    # YES - NO
    
    def self.apply_admin?
      defined?(@model_class::APPLY_ADMIN) and @model_class::APPLY_ADMIN
    end
    
    def self.create_disabled?
      defined?(@model_class::CREATE_DISABLED) and @model_class::CREATE_DISABLED
    end

    def self.delete_disabled?
      defined?(@model_class::DELETE_DISABLED) and @model_class::DELETE_DISABLED
    end

    def self.edit_disabled?
      defined?(@model_class::EDIT_DISABLED) and @model_class::EDIT_DISABLED
    end
    
    def self.active_disabled?
      (defined?(@model_class::ACTIVE_DISABLED) and @model_class::ACTIVE_DISABLED) or defined?(@model_class.new.active).nil?
    end
    
    # TEXT
    def self.title
      defined?(@model_class::TITLE) ? @model_class::TITLE : @model_class.to_s.pluralize
    end
    
    def self.layout_index_style
      default = model_style
      style = defined?(@model_class::LAYOUT_INDEX_STYLE) ? @model_class::LAYOUT_INDEX_STYLE : default
      ['table','library'].include?(style) ? style : default
    end
    
    def self.model_style
      default = 'table'
      style = defined?(@model_class::MODEL_STYLE) ? @model_class::MODEL_STYLE : default
      [default,'library'].include?(style) ? style : default
    end

    def self.image_attribute
      config = defined?(@model_class::IMAGE_ATTRIBUTE) ? @model_class::IMAGE_ATTRIBUTE : nil
      if config.nil?
        @model_class.columns.each do |column|
          return column.name[0..-11] if column.name[-9..-1] == 'file_name'
        end
      end
      return config
    end
    
    def self.image_style_thumb
      defined?(@model_class::IMAGE_STYLE_THUMB) ? @model_class::IMAGE_STYLE_THUMB : 'original'
    end
      
    def self.image_style_medium
      defined?(@model_class::IMAGE_STYLE_MEDIUM) ? @model_class::IMAGE_STYLE_MEDIUM : 'original'
    end
    
    def self.add_link(params)
      add_link_hash(params).to_query
    end
    
    # HASH
    
    def self.add_link_hash(params)
      hash = {}
      params.each do |param|
        key = param[0].gsub('/', '') 
        hash[key] = param[1] if param[0].last(3) == "_id"
      end
      hash
    end
    
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
          hash[key] = obj.send(key.downcase) rescue "#"
        end
        
        if hash[key].class.to_s.index("ActiveRecord_Associations_CollectionProxy")
          add_update_tool = false
          list = []
          hash[key].each do |item|
            text = defined?(item.represent_text) ? item.represent_text : item.to_s
            model_string = item.class.name.downcase
            list << "<li><a href='/#{AntsAdmin.admin_path}/#{model_string}/#{item.id}/edit' back-href='/#{AntsAdmin.admin_path}/#{obj.class.name.downcase}' back-level='2'>#{text}</a></li>"
          end
          hash[key] = html_show_list_with_has_many(list)
        else
          add_update_tool = false
          hash[key] = defined?(hash[key].represent_text) ? hash[key].represent_text : hash[key].to_s
        end

        if add_update_tool
          sub_table = obj.send(value.downcase) rescue false
          if sub_table
            hash[key] = [
              "<div class='select_edit'>",
              "<span>#{hash[key]}</span>",
              "<a class='fa fa-cog' href='#'></a>",
              "<data type='#{key[0..-4]}' value='#{sub_table.id}' obj-id='#{obj.id}' model='#{obj.class.name.downcase}'/>",
              "</div>"].join
          end
        end
      end
      return hash
    end
    
    # Skins
    
    ## Buttons HTML
    
    def self.html_button_delete
      (defined?(@model_class::HTML_BUTTON_DELETE) ? @model_class::HTML_BUTTON_DELETE : '<i class="fa fa-trash-o"></i>').html_safe
    end
    
    def self.html_button_edit
      (defined?(@model_class::HTML_BUTTON_EDIT) ? @model_class::HTML_BUTTON_EDIT : '<i class="fa fa-pencil-square-o"></i>').html_safe
    end
    
    def self.html_button_activated
      (defined?(@model_class::HTML_BUTTON_ACTIVATED) ? @model_class::HTML_BUTTON_ACTIVATED : '<i class="fa fa-unlock"></i>').html_safe
    end
    
    def self.html_button_deactivated
      (defined?(@model_class::HTML_BUTTON_DEACTIVATED) ? @model_class::HTML_BUTTON_DEACTIVATED : '<i class="fa fa-lock"></i>').html_safe
    end
    
    private
    
    def self.html_show_list_with_has_many(list)
      html = list.length > 0 ? "<a class='fa fa-list show-btn-list btn btn-sm btn-default' href='#'></a><ul class='btn-list'>#{list.join}<a class='close_list fa fa-times'></a></ul>" : ""
    end
    
    def self.json_with_file(obj, key)
      type = obj.send("#{key}_content_type")
      style = obj.send(key).styles.present? ? image_style_thumb : 'original'
      url = obj.send(key).url(style)
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
      return  type ? (icon == 'image' ? "<a href='#{obj.send(key).url}' class='review_image'><img src='#{url}' class='cover file' title='#{file_name}'/></a>" : "<a href='#{obj.send("#{key}").url}' target='_blank' class='btn btn-default file fa fa-#{icon}' title='#{file_name}'></a>") : ""
    end
    
    def self.attribute_show(obj, attr_name)
      return obj.send("#{attr_name}_show") rescue obj.send(attr_name)
    end
    
    protected
    def self.get_list(config_list)
      return config_list.is_a?(Array) ? config_list : [config_list]
    end

  end
end