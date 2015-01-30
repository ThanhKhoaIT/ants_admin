module AntsAdmin
  module IndexHelper
    
    def actions_link(model_object)
      @object = model_object
      self.send(@model_config.layout_index_style)
    end

    private
    
    def table
     action_content(@model_config.actions_link, "btn-group")
    end
    
    def library
      action_content(@model_config.actions_link.select{|action| action != 'edit'}, "btn-group tool_library")
    end
    
    protected
    
    def action_content(actions_link, class_style)
      actions_html = []
      
      actions_link.each do |action_link|
        case action_link
        when "edit"
          actions_html << add_edit
        when "active"
          actions_html << add_active
        when "remove"
          actions_html << add_remove
        else
          actions_html << custom_action(action_link) rescue ""
        end
      end

      return content_tag(:div, actions_html.join().html_safe, class: class_style)
    end
    
    def add_edit
      content_tag(:a, @model_config.html_button_edit,
                    href: ["/#{AntsAdmin.admin_path}",@object.class.name.tableize,@object.id,"edit"].join("/"),
                    class: "btn btn-sm btn-success",
                    'back-href'=> "/#{AntsAdmin.admin_path}/#{@object.class.name.tableize}",
                    'back-level'=> "2")
    end
    
    def add_remove
      content_tag(:a, @model_config.html_button_delete,
                    href:           ["/#{AntsAdmin.admin_path}",@object.class.name.tableize,"#{@object.id}?#{@params_add_form.to_query}"].join("/"),
                    'data-method'=> 'delete',
                    class:          'btn btn-sm btn-danger',
                    confirm:        'Are you sure?')
    end
    
    def add_active
      content_tag(:a, 
                    [ @model_config.html_button_activated,
                      @model_config.html_button_deactivated,
                      '<i class="fa fa-gear fa-spin"></i>'].join().html_safe,
                    href: ["/#{AntsAdmin.admin_path}",@object.class.name.tableize, @object.id, "active"].join("/"),
                    class: "active-link btn btn-sm btn-#{@object.active ? "primary actived" : "warning"}")
    end
    
    def custom_action(action_link)
      called = @object.send("#{action_link}_action")
      return "<a href='/#{AntsAdmin.admin_path}/errors/config_action?model=#{@object.class.downcase}&def=#{action_link}_action' class='btn btn-sm btn-danger'>#{action_link}</a>" if called.nil?
      return called if called.is_a?(String)
      return "<a href='#{called[:button][:href]}' class='btn btn-sm btn-#{called[:button][:style]}'>#{called[:button][:icon] ? "<i class='fa fa-#{called[:button][:icon]}'></i>" : called[:button][:text]}</a>" if called.is_a?(Hash) and called[:button]
    end

  end
end