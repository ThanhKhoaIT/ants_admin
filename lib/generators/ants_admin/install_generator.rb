require 'rails/generators/base'
require 'securerandom'

module AntsAdmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a AntsAdmin initializer and copy locale files to your application."
      class_option :orm

      def copy_files
        template "devise.rb", "config/initializers/devise.rb"
        template "ants_admin.rb", "config/initializers/ants_admin.rb"
        template "dashboard.html.erb", "app/views/ants_admin/dashboard.html.erb"
        template "form.yml", "config/ants_admin/form.yml"
        template "devise.en.yml", "config/locales/devise.en.yml"
      end
            
      def copy_devise_files
        inject_into_file 'config/initializers/assets.rb', after: "Rails.application.config.assets.version = '1.0'\n" do <<-'RUBY'
Rails.application.config.assets.precompile += %w( devise.css )
Rails.application.config.assets.precompile += %w( devise.js )
        RUBY
        end
        
        directory "assets/devise_images", "app/assets/images/devise"
        directory "assets/devise_js", "app/assets/javascripts/devise"
        directory "assets/devise_css", "app/assets/stylesheets/devise"
        directory "devise", "app/views/devise"
        
        template "assets/devise.css", "app/assets/stylesheets/devise.css"
        template "assets/devise.js", "app/assets/javascripts/devise.js"
        copy_file "devise.html.erb", "app/views/layouts/devise.html.erb"
      end
      
      def show_readme
        readme "README" if behavior == :invoke
      end

      def rails_4?
        Rails::VERSION::MAJOR == 4
      end
    end
  end
end
