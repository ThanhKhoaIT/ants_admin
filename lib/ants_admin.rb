require 'rails'
module AntsAdmin
  def self.setup
    yield self        
  end
  class Engine < Rails::Engine
  end
end
