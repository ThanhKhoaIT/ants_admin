module AntsAdmin
  module InputHelper
    def text_input(form, name)
      content_tag(:div, [(form.label name.to_sym),(form.text_field name.to_sym, class: 'form-control')].join().html_safe, class: "form-group")
    end
    
    def file_input(form, name)
      content_tag(:div, [(form.label name.to_sym),(form.file_field name.to_sym)].join().html_safe, class: "form-group")
    end
    
    def time_input(form, name)
      id = "id_#{Random.rand(500) + 10}"
      contents = ['<div class="form-group">', 
        (form.label name),
        '<div class="input-group">',
        (form.text_field name, class: 'form-control timepicker', id: id),
        '<div class="input-group-addon"><i class="fa fa-clock-o"></i></div></div>',
        javascript_tag("$('##{id}').timepicker({showInputs: false})")
      ]
      content_tag(:div, contents.join().html_safe, class: "bootstrap-timepicker")
    end

    def date_input(form, name)
      id = "id_#{Random.rand(500) + 10}"
      contents = [
        (form.label name),
        '<div class="input-group"><div class="input-group-addon"><i class="fa fa-calendar"></i></div>',
        (form.text_field name, id: id, class: 'form-control', 'data-inputmask'=>"'alias':'dd/mm/yyyy'",'data-mask'=>""),
        '</div></div>',
        javascript_tag("$('##{id}').inputmask('dd/mm/yyyy', {placeholder: 'dd/mm/yyyy'})")
      ]
      content_tag(:div, contents.join().html_safe, class: "form-group")
    end

    def number_input(form, name)
      content_tag(:div, [(form.label name.to_sym),(form.text_field name.to_sym, class: 'form-control', type: "number")].join().html_safe, class: "form-group")
    end

    def textarea(form, name)
      content_tag(:div, [(form.label name.to_sym),(form.text_area name.to_sym, class: 'form-control')].join().html_safe, class: "form-group")
    end
    
    def checkbox(form, name)
      content_tag(:div, [(form.label name.to_sym),(form.check_box name.to_sym, class: 'form-control')].join().html_safe, class: "form-group")
    end
  end
end