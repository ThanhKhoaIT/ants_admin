require 'rails'
require 'ants_admin/smart_model'

module AntsAdmin
  def self.setup
    yield self
  end
  class Engine < Rails::Engine
  end
  
  mattr_accessor :name_show
  @@name_show = 'Ants Admin'
  
  mattr_accessor :registerable
  @@registerable = true
  
  mattr_accessor :recoverable
  @@recoverable = true

end