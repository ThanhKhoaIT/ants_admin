module AntsAdmin
  module InputHelper
    def text_input(form, name)
      content_tag(:div, [(form.label name.to_sym),(form.text_field name.to_sym, class: 'form-control')].join().html_safe, class: "form-group")
    end
    
    def file_input(form, name)
      type = form.object["#{name}_content_type"] rescue ""
      type = file_type(type) if type
      if type == "image"
        image = image_tag(form.object.send(name).url, class: 'cover-file-form')
        html = link_to(image.html_safe, form.object.send(name).url, class: 'review_image', title: "#{form.object.send("#{name}_file_name")}")
      else
        html = content_tag(:i, "", class: "cover-file-form fa fa-#{type}")
      end
      
      html += content_tag(:span, form.object.send("#{name}_file_name")) rescue "not file"
      
      upload_button = content_tag(:span, ["<i class='fa fa-cloud-upload'></i>", (form.file_field name.to_sym)].join.html_safe, class: 'btn btn-default btn-file')
      
      thumb = type ? content_tag(:div, html.html_safe, class: "thumb") : ""
      
      content_tag(:div, [(form.label name.to_sym, for: false),thumb,upload_button].join().html_safe, class: "form-group file-upload")
    end
    
    def file_input_upload_only(form, name)
      content_tag(:div, (form.file_field name.to_sym), class: 'fa fa-cloud-upload action-page', id: 'add_upload')
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
        '</div>',
        javascript_tag("$('##{id}').inputmask('dd/mm/yyyy', {placeholder: 'dd/mm/yyyy'})")
      ]
      content_tag(:div, contents.join().html_safe, class: "form-group")
    end

    def number_input(form, name)
      content_tag(:div, [(form.label name.to_sym),(form.text_field name.to_sym, class: 'form-control', type: "number")].join().html_safe, class: "form-group")
    end

    def textarea(form, name)
      id = random_id
      js_tag = javascript_tag("$('.#{id}').editable({inlineMode: false})") if !@model_config.textarea_only.include?(name)
      content_tag(:div, [(form.label name.to_sym),(form.text_area name.to_sym, class: "form-control #{id}"), js_tag].join().html_safe, class: "form-group")
    end
    
    def checkbox(form, name)
      content_tag(:div, [(form.label name.to_sym, class: 'label_select'),(form.check_box name.to_sym, class: 'form-control flat-blue')].join().html_safe, class: "form-group")
    end
    
    def select_input(form, name)
      select_box_class = (0...8).map{(65+rand(26)).chr}.join
      class_model = name[0..-4]
      model_class = class_model.singularize.classify.constantize
      all = model_class.load_select_box rescue model_class.all
      collection = all.collect{|item| [represent_text(item) , item.id]}
      collection = collection.sort_by{|item| item[0]}

      content_tag(:div, [
        (form.label name.to_sym, class: 'label_with_ajax_add'),
        (form.select name, collection, {}, {class: "form-control with_ajax_add select_#{select_box_class}"}),
        content_tag(:a, '',
          href: '#',
          iframe_link: "/#{AntsAdmin.admin_path}/#{class_model}/add",
          iframe_callback: 'updateSelectBox',
          iframe_params: ".select_#{select_box_class},#{class_model}",
          class: 'fa fa-plus add_btn_ajax_select_box'
        )
          
      ].join().html_safe, class: "form-group with_ajax_add")
    end
    
    def select_input_boolean(form, name)
      input_config = form.object.send("input_#{name}") rescue nil
      collection = input_config[:collection]
      content_tag(:div, [
        (form.label name.to_sym),
        (form.select name, collection, {}, {class: "form-control"})
          
      ].join().html_safe, class: "form-group")
    end


    def link_to_add_fields(f, association)
      new_object = association.classify.constantize.new
      fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
        begin
          render(["/ants_admin",@object.class.name.pluralize.downcase,association.to_s.singularize + "_nested"].join("/"), :form => builder, item: association)
        rescue
          render("/ants_admin/nested_form", :form => builder, item: association)
        end
      end
      link_to_function('plus btn-success', "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
    end
    
    def link_to_remove_fields(f)
      f.hidden_field(:_destroy) + link_to_function('times btn-danger', "remove_fields(this)")
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
    
    def link_to_function(icon, *args, &block)
      html_options = args.extract_options!.symbolize_keys

      function = block_given? ? update_page(&block) : args[0] || ''
      onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
      href = html_options[:href] || '#'

      content_tag(:a, "", html_options.merge(:href => href, :onclick => onclick, class: "btn fa fa-#{icon} float-right"))
    end
    
    def random_id
      (0...15).map { (65 + rand(26)).chr }.join.downcase
    end

  end
end