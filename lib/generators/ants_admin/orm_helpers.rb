module AntsAdmin
  module Generators
    module OrmHelpers
      def model_contents
        buffer = <<-CONTENT
        
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable
         
  has_attached_file :avatar, :styles => { :medium => "300x300#", :thumb => "100x100>" }, :default_url => "/assets/devise/avatar.png"
  validates_attachment_content_type :avatar, :content_type => \/\\Aimage\\\/.*\\Z\/
  
  require "digest/md5"

  def full_name
    [first_name, last_name].join(' ')
  end

  def avatar_show
    if avatar.url != '/assets/devise/avatar.png'
      avatar.url(:medium)
    else
      options = {gravatar_id: Digest::MD5.hexdigest(email)}
      "http://www.gravatar.com/avatar.php?" + options.to_query
    end
  end
         
  def login=(login)
    @login = login
  end

  def login
    @login || self.username || self.email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end


  def self.find_first_by_auth_conditions(warden_conditions)
	  conditions = warden_conditions.dup
	  if login = conditions.delete(:login)
	    where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
	  else
	    where(conditions).first
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