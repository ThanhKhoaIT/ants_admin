require 'rails/generators/named_base'

module AntsAdmin
  module Generators
    class AntsAdminGenerator < Rails::Generators::Base
      include Rails::Generators::ResourceHelpers
      
      namespace "ants_admin"
      source_root File.expand_path("../templates", __FILE__)
      argument :params, type: :array, default: [], banner: "field:type field:type"
      hook_for :orm
      def name
        @name = params.present? ? params[0] : "account"
      end
    end
  end
end