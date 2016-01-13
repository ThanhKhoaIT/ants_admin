require 'rails/generators/base'
require 'securerandom'
require 'rails/generators/active_record'
require 'generators/ants_admin/ants_admin_libraries/orm_helpers'

module AntsAdmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include AntsAdmin::Generators::AntsAdminLibraries::OrmHelpers

      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a AntsAdmin initializer and copy locale files to your application."
      class_option :orm


      # Install Ants Admin Libraries
      def copy_ants_admin_libraries_migration
        template "ants_admin_libraries/migration.rb", "db/migrate/#{Time.zone.now.strftime("%Y%m%d%H%M%S")}_ants_admin_create_ants_admin_libraries.rb" if !migration_exists?
      end

      def generate_model_ants_admin_libraries
        invoke "active_record:model", ['ants_admin_library'], migration: false unless model_exists? && behavior == :invoke
      end

      def inject_ants_admin_libraries_content
        inject_into_file model_path, after: "class AntsAdminLibrary < ActiveRecord::Base\n" do
          model_contents
        end if model_exists?
      end

      def migration_data
<<RUBY
      t.attachment :photo
      t.string :title
RUBY
      end

      # Install Ants Admin
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
