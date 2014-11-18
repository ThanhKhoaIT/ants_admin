AntsAdmin.setup do |config|
  # Main model for login
  config.model_security = "Account"  
  
  # Allow for register
  config.registerable = true
  
  # Allow for forgot password
  config.recoverable = true
end