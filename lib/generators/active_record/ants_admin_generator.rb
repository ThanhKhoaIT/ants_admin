require 'rails/generators/active_record'
require 'generators/ants_admin/orm_helpers'

module ActiveRecord
  module Generators
    class AntsAdminGenerator < ActiveRecord::Generators::Base
      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      include AntsAdmin::Generators::OrmHelpers
      
      source_root File.expand_path("../templates", __FILE__)

      def copy_ants_admin_migration
        if (behavior == :invoke && model_exists?) || (behavior == :revoke && migration_exists?(table_name))
          migration_template "migration_existing.rb", "db/migrate/add_ants_admin_to_#{table_name}.rb"
        else
          migration_template "migration.rb", "db/migrate/ants_admin_create_#{table_name}.rb"
        end
      end

      def generate_model
        invoke "active_record:model", [name], migration: false unless model_exists? && behavior == :invoke
      end

      def inject_ants_admin_content
        content = model_contents
        class_path = if namespaced?
          class_name.to_s.split("::")
        else
          [class_name]
        end
        indent_depth = class_path.size - 1
        content = content.split("\n").map { |line| "  " * indent_depth + line } .join("\n") << "\n"
        inject_into_class(model_path, class_path.last, content) if model_exists?
      end

      def migration_data
<<RUBY
      ## Database authenticatable
      t.attachment :avatar
      t.string :first_name,         null: false
      t.string :last_name,          null: false
      t.string :email,              null: false, default: ""
      t.string :username,           null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      
      t.text     :tokens
      t.boolean  :only_device,      null: false, default: false
      t.boolean  :locked,           null: false, default: false
      t.integer  :timeout,          null: false, default: 3
RUBY
      end
    end
  end
end
