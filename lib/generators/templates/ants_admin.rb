AntsAdmin.setup do |config|
  config.model_security = "Account"
  
  config.registerable = true
  
  config.recoverable = true
end