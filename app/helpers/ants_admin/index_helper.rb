module AntsAdmin
  module IndexHelper
    
    def actions_link(model_object)
      actions_html = []
      
      @model_config.actions_link.each do |action_link|
        case action_link
        when "edit"
          actions_html << content_tag(:a, @model_config.html_button_edit,
                            href: ["/admin",model_object.class.name.downcase,model_object.id,"edit"].join("/"),
                            class: "btn btn-sm btn-success",
                            'back-href'=> "/admin/#{model_object.class.name.downcase}",
                            'back-level'=> "2")
        when "active"
          actions_html << content_tag(:a, 
                        [ @model_config.html_button_activated,
                          @model_config.html_button_deactivated,
                          '<i class="fa fa-gear fa-spin"></i>'].join().html_safe,
                        href: ["/admin",model_object.class.name.downcase,model_object.id,"active"].join("/"),
                        class: "active-link btn btn-sm btn-#{model_object.active ? "primary actived" : "warning"}")
        when "remove"
          actions_html << content_tag(:a, @model_config.html_button_delete,
                            href:   ["/admin",model_object.class.name.downcase,model_object.id].join("/"),
                            'data-method'=> 'delete',
                            class: "btn btn-sm btn-danger",
                            confirm: "Are you sure?",
                            'back-href'=> "/admin/#{model_object.class.name.downcase}",
                            'back-level'=> "2")
        else
          actions_html << model_object.send(action_link)
        end
      end

      return content_tag(:div, actions_html.join().html_safe, class: "btn-group")
    end

  end
end