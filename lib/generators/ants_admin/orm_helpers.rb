module AntsAdmin
  module Generators
    module OrmHelpers
      def model_contents
        buffer = <<-CONTENT
  attr_accessor :login
  def login=(login)
    @login = login
  end

  def login
    @login || self.username || self.email
  end
  
  def password
    nil
  end
  
  def password=(password)
    self.encrypted_password = Digest::MD5.hexdigest(password)
  end
  
  def self.login_with_username(username, password)
    login_by = find_by_username(username)
    if login_by and login_by.encrypted_password = Digest::MD5.hexdigest(password)
      return login_by
    else
      return false
    end
  end
    
CONTENT
        buffer += <<-CONTENT if needs_attr_accessible?
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

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

      def migration_exists?(table_name)
        Dir.glob("#{File.join(destination_root, migration_path)}/[0-9]*_*.rb").grep(/\d+_add_ants_admin_to_#{table_name}.rb$/).first
      end

      def migration_path
        @migration_path ||= File.join("db", "migrate")
      end

      def model_path
        @model_path ||= File.join("app", "models", "#{file_path}.rb")
      end
    end
  end
end