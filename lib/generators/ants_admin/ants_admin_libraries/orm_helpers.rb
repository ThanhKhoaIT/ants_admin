module AntsAdmin
  module Generators
    module AntsAdminLibraries
      module OrmHelpers
        def model_contents
          buffer = <<-CONTENT
    has_attached_file :photo, :styles => { :medium => "300x300#", :thumb => "100x100>" }, :default_url => "/assets/default-photo.png"
    validates_attachment_content_type :photo, :content_type => \/\\Aimage\\\/.*\\Z\/
          CONTENT
          buffer
        end

        def needs_attr_accessible?
          rails_3? && !strong_parameters_enabled?
        end

        def rails_3?
          Rails::VERSION::MAJOR == 3
        end

        def strong_parameters_enabled?
          defined?(ActionController::StrongParameters)
        end

        private

        def model_exists?
          File.exists?(File.join(destination_root, model_path))
        end

        def migration_exists?
          Dir["db/migrate/*_ants_admin_create_ants_admin_libraries.rb"].length > 0
        end

        def model_path
          @model_path ||= File.join("app", "models", "ants_admin_library.rb")
        end
      end
    end
  end
end