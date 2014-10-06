module AntsAdmin
  module FormHelper
    
    def resource_model
      resource_name.constantize
    end

    def resource_name
      AntsAdmin.model_security.to_s
    end

    def registerable?
      AntsAdmin.registerable
    end
  
    def recoverable?
      AntsAdmin.recoverable
    end
    
  end
end