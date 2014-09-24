require 'rails'
require 'orm_adapter'
require 'set'

module AntsAdmin
  class Getter
    def initialize name
      @name = name
    end
    def get
      ActiveSupport::Dependencies.constantize(@name)
    end
  end
  def self.ref(arg)
    if defined?(ActiveSupport::Dependencies::ClassCache)
      ActiveSupport::Dependencies::reference(arg)
      Getter.new(arg)
    else
      ActiveSupport::Dependencies.ref(arg)
    end
  end
    
  def self.setup
    yield self        
  end
  class Engine < Rails::Engine
  end
end
