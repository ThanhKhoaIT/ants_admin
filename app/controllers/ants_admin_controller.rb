class AntsAdminController < AntsAdmin.parent_controller.constantize
  
  include AntsAdmin::Controllers::ScopedViews

  helper AntsAdminHelper

  helpers = %w(resource scope_name resource_name signed_in_resource
               resource_class resource_params ants_admin_mapping)
  hide_action *helpers
  helper_method *helpers

  prepend_before_filter :assert_is_ants_admin_resource!
  respond_to :html if mimes_for_respond_to.empty?

  def index
  end

  # Gets the actual resource stored in the instance variable
  def resource
    instance_variable_get(:"@#{resource_name}")
  end

  # Proxy to ants_admin map name
  def resource_name
    ants_admin_mapping.name
  end
  alias :scope_name :resource_name

  # Proxy to ants_admin map class
  def resource_class
    ants_admin_mapping.to
  end

  # Returns a signed in resource from session (if one exists)
  def signed_in_resource
    warden.authenticate(scope: resource_name)
  end

  # Attempt to find the mapped route for ants_admin based on request path
  def ants_admin_mapping
    @ants_admin_mapping ||= request.env["ants_admin.mapping"]
  end

  # Override prefixes to consider the scoped view.
  # Notice we need to check for the request due to a bug in
  # Action Controller tests that forces _prefixes to be
  # loaded before even having a request object.
  def _prefixes #:nodoc:
    @_prefixes ||= if self.class.scoped_views? && request && ants_admin_mapping
      super.unshift("#{ants_admin_mapping.scoped_path}/#{controller_name}")
    else
      super
    end
  end

  hide_action :_prefixes

  protected

  # Checks whether it's a ants_admin mapped resource or not.
  def assert_is_ants_admin_resource! #:nodoc:
    unknown_action! <<-MESSAGE unless ants_admin_mapping
Could not find ants_admin mapping for path #{request.fullpath.inspect}.
This may happen for two reasons:

1) You forgot to wrap your route inside the scope block. For example:

  ants_admin_scope :user do
    get "/some/route" => "some_ants_admin_controller"
  end

2) You are testing a AntsAdmin controller bypassing the router.
   If so, you can explicitly tell AntsAdmin which mapping to use:

   @request.env["ants_admin.mapping"] = AntsAdmin.mappings[:user]

MESSAGE
  end

  # Returns real navigational formats which are supported by Rails
  def navigational_formats
    @navigational_formats ||= AntsAdmin.navigational_formats.select { |format| Mime::EXTENSION_LOOKUP[format.to_s] }
  end

  def unknown_action!(msg)
    logger.debug "[AntsAdmin] #{msg}" if logger
    raise AbstractController::ActionNotFound, msg
  end

  # Sets the resource creating an instance variable
  def resource=(new_resource)
    instance_variable_set(:"@#{resource_name}", new_resource)
  end

  # Helper for use in before_filters where no authentication is required.
  #
  # Example:
  #   before_filter :require_no_authentication, only: :new
  def require_no_authentication
    assert_is_ants_admin_resource!
    return unless is_navigational_format?
    no_input = ants_admin_mapping.no_input_strategies

    authenticated = if no_input.present?
      args = no_input.dup.push scope: resource_name
      warden.authenticate?(*args)
    else
      warden.authenticated?(resource_name)
    end

    if authenticated && resource = warden.user(resource_name)
      flash[:alert] = I18n.t("ants_admin.failure.already_authenticated")
      redirect_to after_sign_in_path_for(resource)
    end
  end

  # Helper for use after calling send_*_instructions methods on a resource.
  # If we are in paranoid mode, we always act as if the resource was valid
  # and instructions were sent.
  def successfully_sent?(resource)
    notice = if AntsAdmin.paranoid
      resource.errors.clear
      :send_paranoid_instructions
    elsif resource.errors.empty?
      :send_instructions
    end

    if notice
      set_flash_message :notice, notice if is_flashing_format?
      true
    end
  end

  # Sets the flash message with :key, using I18n. By default you are able
  # to setup your messages using specific resource scope, and if no one is
  # found we look to default scope.
  # Example (i18n locale file):
  #
  #   en:
  #     ants_admin:
  #       passwords:
  #         #default_scope_messages - only if resource_scope is not found
  #         user:
  #           #resource_scope_messages
  #
  # Please refer to README or en.yml locale file to check what messages are
  # available.
  def set_flash_message(key, kind, options = {})
    message = find_message(kind, options)
    flash[key] = message if message.present?
  end

  def ants_admin_i18n_options(options)
    options
  end

  # Get message for given
  def find_message(kind, options = {})
    options[:scope] = "ants_admin.#{controller_name}"
    options[:default] = Array(options[:default]).unshift(kind.to_sym)
    options[:resource_name] = resource_name
    options = ants_admin_i18n_options(options)
    I18n.t("#{options[:resource_name]}.#{kind}", options)
  end

  def clean_up_passwords(object)
    object.clean_up_passwords if object.respond_to?(:clean_up_passwords)
  end

  def respond_with_navigational(*args, &block)
    respond_with(*args) do |format|
      format.any(*navigational_formats, &block)
    end
  end

  def resource_params
    params.fetch(resource_name, {})
  end
end