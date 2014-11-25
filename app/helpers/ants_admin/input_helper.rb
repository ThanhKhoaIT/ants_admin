module AntsAdmin
  module InputHelper
    def text_input(form, name)
      content_tag(:div, [(form.label name.to_sym),(form.text_field name.to_sym, class: 'form-control')].join().html_safe, class: "form-group")
    end
    
    def file_input(form, name)
      type = form.object["#{name}_content_type"]
      type = file_type(type) if type
      if type == "image"
        image = image_tag(form.object.send(name).url, class: 'cover-file-form')
        html = link_to(image.html_safe, form.object.send(name).url, class: 'review_image', title: "#{form.object.send("#{name}_file_name")}")
      else
        html = content_tag(:i, "", class: "cover-file-form fa fa-#{type}")
      end
      
      html += content_tag(:span, form.object.send("#{name}_file_name"))
      
      upload_button = content_tag(:span, ["Upload", (form.file_field name.to_sym)].join.html_safe, class: 'btn btn-default')
      
      thumb = type ? content_tag(:div, html.html_safe, class: "thumb") : ""
      
      content_tag(:div, [(form.label name.to_sym),thumb,upload_button].join().html_safe, class: "form-group file-upload")
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
    
    def select_input(form, name)
      select_box_class = (0...8).map{(65+rand(26)).chr}.join
      class_model = name[0..-4]
      collection = class_model.singularize.classify.constantize.all.collect{|item| [represent_text(item) , item.id]}
      collection = collection.sort_by{|item| item[0]}
      content_tag(:div, [
        (form.label name.to_sym, class: 'label_with_ajax_add'),
        (form.select name, collection, {}, {class: "form-control with_ajax_add select_#{select_box_class}"}),
        content_tag(:a, '', href: '#', iframe_link: "/admin/#{class_model}/add", iframe_callback: 'updateSelectBox', iframe_params: ".select_#{select_box_class},#{class_model}", class: 'fa fa-plus add_btn_ajax_select_box')
      ].join().html_safe, class: "form-group with_ajax_add")
      
    end

    protected
    
    def file_type(type)
      types = {
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
      return types[type] || 'paperclip'
    end

  end
end