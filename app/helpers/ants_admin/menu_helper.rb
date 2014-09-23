module AntsAdmin
  module MenuHelper
    def main_menu_ants_admin(data, opts={})
      @contents = []
      data.each do |li|
        li_class = []
        li_content = []
        a_content = []
        submenu = []
        
        li_class.push('active') if li[:active] 
        a_content.push(content_tag(:i,"",class: "fa fa-#{li[:icon]}"))
        a_content.push(content_tag(:span, li[:text]))
        
        a_content.push(content_tag(:small,li[:note][:text],class: "badge pull-right bg-#{li[:note][:color]}")) if li[:note].present?
        if li[:submenu].present?
          a_content.push(content_tag(:i,"",class: "fa fa-angle-left pull-right"))
          li_class.push('treeview')
          li[:submenu].each do |li_submenu|
            submenu.push(content_tag(:li, content_tag(:a, [content_tag(:i,"",class: 'fa fa-angle-double-right'), li_submenu[:text]].join().html_safe, href: li_submenu[:url])))
          end
        end
        
        li_content.push(content_tag(:a, a_content.join().html_safe, href: li[:url]))
        li_content.push(content_tag(:ul, submenu.join().html_safe, class: 'treeview-menu'))
        li_tag = content_tag(:li, li_content.join().html_safe, class: li_class.join(" "))
        @contents.push(li_tag)
      end
      content_tag(:ul, @contents.join().html_safe, class: 'sidebar-menu')
    end
  end
end