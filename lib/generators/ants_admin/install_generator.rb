require 'securerandom'
require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/named_base'

module AntsAdmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::ResourceHelpers
      namespace "ants_admin"
      source_root File.expand_path("../templates", __FILE__)
    
      # Copy config file for my gem
      def create_file_config(a)
        puts "a"
        # template "config/express_translate.yml", "config/express_translate.yml"
      end
    
      def karl
        puts "b"
      end
    end
  end
end