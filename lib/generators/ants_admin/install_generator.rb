require 'securerandom'
require 'rails/generators'
require 'rails/generators/migration'

module AntsAdmin
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    
    # Copy config file for my gem
    def create_file_config(a)
      puts a 
      # template "config/express_translate.yml", "config/express_translate.yml"
    end
    
    def karl
     
    end
  end
end

