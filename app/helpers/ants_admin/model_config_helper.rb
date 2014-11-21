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
      titles = titles.collect{|title| title.is_a?(Hash) ? title : {
        key: title,
        value: [title.slice(0, 1).capitalize, title.slice(1..-1)].join()
      }}
      titles = titles.select{|title| !table_show_skip.include?(title[:value])}
      return titles
    end
    
    def self.table_show_skip
      config_list = []
      config_list = @model_string::TABLE_SHOW_SKIP if defined?(@model_string::TABLE_SHOW_SKIP)
      return [config_list] if !config_list.is_a?(Array)
      return config_list
    end
    
    def self.search_for
      defined?(@model_string::SEARCH_FOR) ? @model_string::SEARCH_FOR : []
    end
    
    def self.actions
      defaults = ['edit','active','remove']
      if defined?(@model_string::ACCTIONS)
        return [] if @model_string::ACCTIONS.is_a?(FalseClass)
        actions = @model_string::ACCTIONS.is_a?(TrueClass) ? defaults : @model_string::ACCTIONS
      else
        actions = defaults
      end
      
      actions = [actions]     if !actions.is_a?(Array)
      actions -= ['edit']     if edit_disabled?
      actions -= ['active']   if active_disabled? or defined?(@model_string.new.active).nil?
      actions -= ['remove']   if delete_disabled?
      return actions
    end
    
    def self.belongs_to_list
      list = []
      @model_string.reflections.select do |assoc_name, ref|
        list << {
          key: "#{assoc_name.to_s}_id",
          value: [assoc_name.to_s.slice(0, 1).capitalize, assoc_name.to_s.slice(1..-1)].join()
        } if ref.macro.to_s == "belongs_to"
      end
      return list
    end
       
    def self.has_many_list
      list = []
      @model_string.reflections.select do |assoc_name, ref|
        list << {
          key: "#{assoc_name.to_s}_id",
          value: [assoc_name.to_s.slice(0, 1).capitalize, assoc_name.to_s.slice(1..-1)].join()
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
      defined?(@model_string::ACTIVE_DISABLED) and @model_string::ACTIVE_DISABLED
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
        value = title[:value]
        hash[key] = key[-3,3] != "_id" ? obj[key] : obj.send(value.downcase)
        if hash[key].class.to_s.index("ActiveRecord_Associations_CollectionProxy")
          list = []
          hash[key].each do |item|
            list << "<li>#{defined?(item.show) ? item.show : item.to_s}</li>"
          end
          hash[key] = "<a class='fa fa-list show-btn-list btn btn-sm btn-primary #{list.length == 0 ? "disabled" : ""}' href='#'></a><ul class='btn-list'>#{list.join()}</ul>"
        else
          hash[key] = hash[key].to_s
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

  end
end