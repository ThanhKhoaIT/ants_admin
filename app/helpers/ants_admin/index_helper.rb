module AntsAdmin
  module IndexHelper
    
    def actions_link(model_object)
      actions_html = []
      
      actions_html << content_tag(:a, @model_config.html_button_edit, href: ["/admin",model_object.class.name.downcase,model_object.id,"edit"].join("/"), class: "btn btn-sm btn-success") if @model_config.actions.include?("edit")
      
      actions_html << content_tag(:a, [@model_config.html_button_activated, @model_config.html_button_deactivated, '<i class="fa fa-gear fa-spin"></i>'].join().html_safe, href: ["/admin",model_object.class.name.downcase,model_object.id,"active"].join("/"), class: "active-link btn btn-sm btn-#{model_object.active ? "primary actived" : "warning"}") if @model_config.actions.include?("active")
      
      actions_html << content_tag(:a, @model_config.html_button_delete, href: ["/admin",model_object.class.name.downcase,model_object.id].join("/"), 'data-method'=> 'delete', class: "btn btn-sm btn-danger", confirm: "Are you sure?") if @model_config.actions.include?("remove")
      
      return content_tag(:div, actions_html.join().html_safe, class: "btn-group")
    end

  end
end