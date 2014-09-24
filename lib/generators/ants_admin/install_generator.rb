require 'securerandom'
require 'rails/generators'
require 'rails/generators/migration'

module AntsAdmin
  # module Generators
#     class InstallGenerator < Rails::Generators::Base
#       source_root File.expand_path("../templates", __FILE__)
#
#       # Copy config file for my gem
#       def create_file_config(a)
#         puts "a"
#         template "account.rb", "app/models/account.rb"
#       end
#
#       def karl
#         puts "b"
#       end
#     end
#   end
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
  
    include ExpressTranslate
  
    # Copy config file for my gem
    def create_file_config
      template "config/express_translate.yml", "config/express_translate.yml"
    end
  
    # Seed data for redis database
    def seeds_data
      ExpressTranslate.seeds
      Account.reset
    end
  end
  end