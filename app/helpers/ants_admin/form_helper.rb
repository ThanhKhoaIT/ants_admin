module AntsAdmin
  module FormHelper
    
    def resource_model
      resource_name.constantize
    end

    def registerable?
      AntsAdmin.registerable
    end
  
    def recoverable?
      AntsAdmin.recoverable
    end
    
    def title(model_class)
      (defined? model_class::TITLE).present? ? model_class::TITLE : model_class
    end
    
    def inputs_form(model_class)
      (defined? model_class::INPUTS_FORM).present? ? model_class::INPUTS_FORM : []
    end

  end
end