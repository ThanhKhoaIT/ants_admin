module AntsAdmin
  module IndexHelper
    
    def actions_link(model_class)
      actions = defined?(model_class.class::ACCTIONS) ? model_class.class::ACCTIONS : ['edit','remove']
      actions_html = []
      
      actions_html << content_tag(:a, '<i class="fa fa-pencil-square-o"></i>'.html_safe, href: ["/admin",model_class.class.name.downcase,model_class.id,"edit"].join("/"), class: "btn btn-sm btn-warning") if actions.include?("edit")
      
      actions_html << content_tag(:a, '<i class="fa fa-trash-o"></i>'.html_safe, href: ["/admin",model_class.class.name.downcase,model_class.id].join("/"), 'data-method'=> 'delete', class: "btn btn-sm btn-danger", confirm: "Are you sure?") if actions.include?("remove")
      
      return content_tag(:div, actions_html.join().html_safe, class: "btn-group")
    end

  end
end