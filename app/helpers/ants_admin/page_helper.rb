module AntsAdmin
  module PageHelper    
    
    def name_show
      AntsAdmin.name_show
    end
    
    def represent_text(obj)
      defined?(obj.represent_text) ? obj.represent_text : obj.to_s
    end
    
    def user_represent_text
      defined?(@current_user.full_name) ? @current_user.full_name : (defined?(@current_user.email) ? @current_user.email : @current_user.to_s)
    end

  end
end