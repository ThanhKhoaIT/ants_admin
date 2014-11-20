module AntsAdmin
  module PageHelper
    def create_disabled(model_class)
      !create_enabled(model_class)
    end
    
    def create_enabled(model_class)
      defined?(model_class::CREATE_DISABLED).nil? or !model_class::CREATE_DISABLED
    end
    
    def table_title(model_class)
      titles = defined?(model_class::TABLE_SHOW) ? model_class::TABLE_SHOW : ["id"]
      titles.collect{|column| (column.slice(0,1).capitalize + column.slice(1..-1))}
    end
    
    def name_show
      AntsAdmin.name_show
    end


  end
end