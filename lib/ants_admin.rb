require 'rails'

module AntsAdmin
  def self.setup
    yield self
  end
  class Engine < Rails::Engine
  end
  
  mattr_accessor :model_security
  @@model_security = nil

end