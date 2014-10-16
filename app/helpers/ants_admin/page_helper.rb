module AntsAdmin
  module PageHelper
    def create_disabled(model_class)
      !create_enabled(model_class)
    end
    
    def create_enabled(model_class)
      defined?(@model_class::CREATE_DISABLED).nil? or !@model_class::CREATE_DISABLED
    end
  end
end