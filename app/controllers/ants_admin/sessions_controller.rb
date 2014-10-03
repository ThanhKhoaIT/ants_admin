class AntsAdmin::SessionsController < AntsAdminController
  layout "account"
  
  # prepend_before_filter :require_no_authentication, only: [ :new, :create ]
#   prepend_before_filter :allow_params_authentication!, only: :create
#   prepend_before_filter only: [ :create, :destroy ] { request.env["ants_admin.skip_timeout"] = true }

  # GET /admin/sign_in
  def new
    model_name = AntsAdmin.model_security.to_s.constantize
    puts model_name
    # resource = model_name.new
  end

  # POST /admin/sign_in
  def create
   
  end

  # DELETE /admin/sign_out
  def destroy
    
  end

  protected

  def sign_in_params
    ants_admin_parameter_sanitizer.sanitize(:sign_in)
  end

  def serialize_options(resource)
    methods = resource_class.authentication_keys.dup
    methods = methods.keys if methods.is_a?(Hash)
    methods << :password if resource.respond_to?(:password)
    { methods: methods, only: [:password] }
  end

  def auth_options
    { scope: resource_name, recall: "#{controller_path}#new" }
  end
end
