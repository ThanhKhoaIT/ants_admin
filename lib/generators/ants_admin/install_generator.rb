require 'rails/generators/base'
require 'securerandom'

module AntsAdmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a AntsAdmin initializer and copy locale files to your application."
      class_option :orm

      def copy_initializer
        template "ants_admin.rb", "config/initializers/ants_admin.rb"
      end
      
      def copy_dashboard_html
        template "dashboard.html.erb", "app/views/ants_admin/dashboard.html.erb"
      end

      def show_readme
        # readme "README" if behavior == :invoke
      end

      def rails_4?
        Rails::VERSION::MAJOR == 4
      end
    end
  end
end
