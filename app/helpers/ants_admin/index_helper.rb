module AntsAdmin
  module IndexHelper
    
    def actions_link(model_object)
      @object = model_object
      self.send(@model_config.layout_index_style)
    end

    private
    
    def table
      actions_html = []
      
      @model_config.actions_link.each do |action_link|
        case action_link
        when "edit"
          actions_html << add_edit
        when "active"
          actions_html << add_active
        when "remove"
          actions_html << add_remove
        else
          actions_html << @object.send(action_link) rescue ""
        end
      end

      return content_tag(:div, actions_html.join().html_safe, class: "btn-group")
    end
    
    def library
      actions_html = []
      
      @model_config.actions_link.each do |action_link|
        case action_link
        when "active"
          actions_html << add_active
        when "remove"
          actions_html << add_remove
        else
          actions_html << @object.send(action_link) rescue ""
        end
      end

      return content_tag(:div, actions_html.join().html_safe, class: "btn-group tool_library")
    end
    
    protected
    
    def add_edit
      content_tag(:a, @model_config.html_button_edit,
                    href: ["/admin",@object.class.name.downcase,@object.id,"edit"].join("/"),
                    class: "btn btn-sm btn-success",
                    'back-href'=> "/admin/#{@object.class.name.downcase}",
                    'back-level'=> "2")
    end
    
    def add_remove
      content_tag(:a, @model_config.html_button_delete,
                    href:   ["/admin",@object.class.name.downcase,@object.id].join("/"),
                    'data-method'=> 'delete',
                    class: "btn btn-sm btn-danger",
                    confirm: "Are you sure?",
                    'back-href'=> "/admin/#{@object.class.name.downcase}",
                    'back-level'=> "2")
    end
    
    def add_active
      content_tag(:a, 
                    [ @model_config.html_button_activated,
                      @model_config.html_button_deactivated,
                      '<i class="fa fa-gear fa-spin"></i>'].join().html_safe,
                    href: ["/admin",@object.class.name.downcase,@object.id,"active"].join("/"),
                    class: "active-link btn btn-sm btn-#{@object.active ? "primary actived" : "warning"}")
    end
    
  end
end