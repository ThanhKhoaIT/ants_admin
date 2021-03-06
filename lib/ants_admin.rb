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

  mattr_accessor :admin_path
  @@admin_path = 'admin'

  mattr_accessor :registerable
  @@registerable = true

end
