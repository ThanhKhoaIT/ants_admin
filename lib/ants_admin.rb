require 'rails'
require 'ants_admin/smart_model'

module AntsAdmin
  def self.setup
    yield self
  end
  class Engine < Rails::Engine
  end
  
  mattr_accessor :model_security
  @@model_security = 'Account'
  
  mattr_accessor :registerable
  @@registerable = true
  
  mattr_accessor :recoverable
  @@recoverable = true

end