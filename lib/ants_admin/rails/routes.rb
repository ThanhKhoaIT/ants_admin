require "active_support/core_ext/object/try"
require "active_support/core_ext/hash/slice"

module ActionDispatch::Routing
  class RouteSet #:nodoc:
    # Ensure AntsAdmin modules are included only after loading routes, because we
    # need ants_admin_for mappings already declared to create filters and helpers.
    def finalize_with_ants_admin!
      result = finalize_without_ants_admin!

      @ants_admin_finalized ||= begin
        if AntsAdmin.router_name.nil? && defined?(@ants_admin_finalized) && self != Rails.application.try(:routes)
          warn "[DEVISE] We have detected that you are using ants_admin_for inside engine routes. " \
            "In this case, you probably want to set AntsAdmin.router_name = MOUNT_POINT, where "   \
            "MOUNT_POINT is a symbol representing where this engine will be mounted at. For "   \
            "now AntsAdmin will default the mount point to :main_app. You can explicitly set it"   \
            " to :main_app as well in case you want to keep the current behavior."
        end

        AntsAdmin.configure_warden!
        AntsAdmin.regenerate_helpers!
        true
      end

      result
    end
    alias_method_chain :finalize!, :ants_admin
  end

  class Mapper
    # Includes ants_admin_for method for routes. This method is responsible to
    # generate all needed routes for ants_admin, based on what modules you have
    # defined in your model.
    #
    # ==== Examples
    #
    # Let's say you have an User model configured to use authenticatable,
    # confirmable and recoverable modules. After creating this inside your routes:
    #
    #   ants_admin_for :users
    #
    # This method is going to look inside your User model and create the
    # needed routes:
    #
    #  # Session routes for Authenticatable (default)
    #       new_user_session GET    /users/sign_in                    {controller:"ants_admin/sessions", action:"new"}
    #           user_session POST   /users/sign_in                    {controller:"ants_admin/sessions", action:"create"}
    #   destroy_user_session DELETE /users/sign_out                   {controller:"ants_admin/sessions", action:"destroy"}
    #
    #  # Password routes for Recoverable, if User model has :recoverable configured
    #      new_user_password GET    /users/password/new(.:format)     {controller:"ants_admin/passwords", action:"new"}
    #     edit_user_password GET    /users/password/edit(.:format)    {controller:"ants_admin/passwords", action:"edit"}
    #          user_password PUT    /users/password(.:format)         {controller:"ants_admin/passwords", action:"update"}
    #                        POST   /users/password(.:format)         {controller:"ants_admin/passwords", action:"create"}
    #
    #  # Confirmation routes for Confirmable, if User model has :confirmable configured
    #  new_user_confirmation GET    /users/confirmation/new(.:format) {controller:"ants_admin/confirmations", action:"new"}
    #      user_confirmation GET    /users/confirmation(.:format)     {controller:"ants_admin/confirmations", action:"show"}
    #                        POST   /users/confirmation(.:format)     {controller:"ants_admin/confirmations", action:"create"}
    #
    # ==== Routes integration
    #
    # +ants_admin_for+ is meant to play nicely with other routes methods. For example,
    # by calling +ants_admin_for+ inside a namespace, it automatically nests your ants_admin
    # controllers:
    #
    #     namespace :publisher do
    #       ants_admin_for :account
    #     end
    #
    # The snippet above will use publisher/sessions controller instead of ants_admin/sessions
    # controller. You can revert this change or configure it directly by passing the :module
    # option described below to +ants_admin_for+.
    #
    # Also note that when you use a namespace it will affect all the helpers and methods
    # for controllers and views. For example, using the above setup you'll end with
    # following methods: current_publisher_account, authenticate_publisher_account!,
    # publisher_account_signed_in, etc.
    #
    # The only aspect not affect by the router configuration is the model name. The
    # model name can be explicitly set via the :class_name option.
    #
    # ==== Options
    #
    # You can configure your routes with some options:
    #
    #  * class_name: setup a different class to be looked up by ants_admin, if it cannot be
    #    properly found by the route name.
    #
    #      ants_admin_for :users, class_name: 'Account'
    #
    #  * path: allows you to setup path name that will be used, as rails routes does.
    #    The following route configuration would setup your route as /accounts instead of /users:
    #
    #      ants_admin_for :users, path: 'accounts'
    #
    #  * singular: setup the singular name for the given resource. This is used as the instance variable
    #    name in controller, as the name in routes and the scope given to warden.
    #
    #      ants_admin_for :users, singular: :user
    #
    #  * path_names: configure different path names to overwrite defaults :sign_in, :sign_out, :sign_up,
    #    :password, :confirmation, :unlock.
    #
    #      ants_admin_for :users, path_names: {
    #        sign_in: 'login', sign_out: 'logout',
    #        password: 'secret', confirmation: 'verification',
    #        registration: 'register', edit: 'edit/profile'
    #      }
    #
    #  * controllers: the controller which should be used. All routes by default points to AntsAdmin controllers.
    #    However, if you want them to point to custom controller, you should do:
    #
    #      ants_admin_for :users, controllers: { sessions: "users/sessions" }
    #
    #  * failure_app: a rack app which is invoked whenever there is a failure. Strings representing a given
    #    are also allowed as parameter.
    #
    #  * sign_out_via: the HTTP method(s) accepted for the :sign_out action (default: :get),
    #    if you wish to restrict this to accept only :post or :delete requests you should do:
    #
    #      ants_admin_for :users, sign_out_via: [ :post, :delete ]
    #
    #    You need to make sure that your sign_out controls trigger a request with a matching HTTP method.
    #
    #  * module: the namespace to find controllers (default: "ants_admin", thus
    #    accessing ants_admin/sessions, ants_admin/registrations, and so on). If you want
    #    to namespace all at once, use module:
    #
    #      ants_admin_for :users, module: "users"
    #
    #  * skip: tell which controller you want to skip routes from being created:
    #
    #      ants_admin_for :users, skip: :sessions
    #
    #  * only: the opposite of :skip, tell which controllers only to generate routes to:
    #
    #      ants_admin_for :users, only: :sessions
    #
    #  * skip_helpers: skip generating AntsAdmin url helpers like new_session_path(@user).
    #    This is useful to avoid conflicts with previous routes and is false by default.
    #    It accepts true as option, meaning it will skip all the helpers for the controllers
    #    given in :skip but it also accepts specific helpers to be skipped:
    #
    #      ants_admin_for :users, skip: [:registrations, :confirmations], skip_helpers: true
    #      ants_admin_for :users, skip_helpers: [:registrations, :confirmations]
    #
    #  * format: include "(.:format)" in the generated routes? true by default, set to false to disable:
    #
    #      ants_admin_for :users, format: false
    #
    #  * constraints: works the same as Rails' constraints
    #
    #  * defaults: works the same as Rails' defaults
    #
    # ==== Scoping
    #
    # Following Rails 3 routes DSL, you can nest ants_admin_for calls inside a scope:
    #
    #   scope "/my" do
    #     ants_admin_for :users
    #   end
    #
    # However, since AntsAdmin uses the request path to retrieve the current user,
    # this has one caveat: If you are using a dynamic segment, like so ...
    #
    #   scope ":locale" do
    #     ants_admin_for :users
    #   end
    #
    # you are required to configure default_url_options in your
    # ApplicationController class, so AntsAdmin can pick it:
    #
    #   class ApplicationController < ActionController::Base
    #     def self.default_url_options
    #       { locale: I18n.locale }
    #     end
    #   end
    #
    # ==== Adding custom actions to override controllers
    #
    # You can pass a block to ants_admin_for that will add any routes defined in the block to AntsAdmin's
    # list of known actions.  This is important if you add a custom action to a controller that
    # overrides an out of the box AntsAdmin controller.
    # For example:
    #
    #    class RegistrationsController < AntsAdmin::RegistrationsController
    #      def update
    #         # do something different here
    #      end
    #
    #      def deactivate
    #        # not a standard action
    #        # deactivate code here
    #      end
    #    end
    #
    # In order to get AntsAdmin to recognize the deactivate action, your ants_admin_scope entry should look like this:
    #
    #     ants_admin_scope :owner do
    #       post "deactivate", to: "registrations#deactivate", as: "deactivate_registration"
    #     end
    #
    def ants_admin_for(*resources)
      @ants_admin_finalized = false
      raise_no_secret_key unless AntsAdmin.secret_key
      options = resources.extract_options!

      options[:as]          ||= @scope[:as]     if @scope[:as].present?
      options[:module]      ||= @scope[:module] if @scope[:module].present?
      options[:path_prefix] ||= @scope[:path]   if @scope[:path].present?
      options[:path_names]    = (@scope[:path_names] || {}).merge(options[:path_names] || {})
      options[:constraints]   = (@scope[:constraints] || {}).merge(options[:constraints] || {})
      options[:defaults]      = (@scope[:defaults] || {}).merge(options[:defaults] || {})
      options[:options]       = @scope[:options] || {}
      options[:options][:format] = false if options[:format] == false

      resources.map!(&:to_sym)

      resources.each do |resource|
        mapping = AntsAdmin.add_mapping(resource, options)

        begin
          raise_no_ants_admin_method_error!(mapping.class_name) unless mapping.to.respond_to?(:ants_admin)
        rescue NameError => e
          raise unless mapping.class_name == resource.to_s.classify
          warn "[WARNING] You provided ants_admin_for #{resource.inspect} but there is " <<
            "no model #{mapping.class_name} defined in your application"
          next
        rescue NoMethodError => e
          raise unless e.message.include?("undefined method `ants_admin'")
          raise_no_ants_admin_method_error!(mapping.class_name)
        end

        if options[:controllers] && options[:controllers][:omniauth_callbacks]
          unless mapping.omniauthable?
            msg =  "Mapping omniauth_callbacks on a resource that is not omniauthable\n"
            msg << "Please add `ants_admin :omniauthable` to the `#{mapping.class_name}` model"
            raise msg
          end
        end

        routes  = mapping.used_routes

        ants_admin_scope mapping.name do
          with_ants_admin_exclusive_scope mapping.fullpath, mapping.name, options do
            routes.each { |mod| send("ants_admin_#{mod}", mapping, mapping.controllers) }
          end
        end
      end
    end

    # Allow you to add authentication request from the router.
    # Takes an optional scope and block to provide constraints
    # on the model instance itself.
    #
    #   authenticate do
    #     resources :post
    #   end
    #
    #   authenticate(:admin) do
    #     resources :users
    #   end
    #
    #   authenticate :user, lambda {|u| u.role == "admin"} do
    #     root to: "admin/dashboard#show", as: :user_root
    #   end
    #
    def authenticate(scope=nil, block=nil)
      constraints_for(:authenticate!, scope, block) do
        yield
      end
    end

    # Allow you to route based on whether a scope is authenticated. You
    # can optionally specify which scope and a block. The block accepts
    # a model and allows extra constraints to be done on the instance.
    #
    #   authenticated :admin do
    #     root to: 'admin/dashboard#show', as: :admin_root
    #   end
    #
    #   authenticated do
    #     root to: 'dashboard#show', as: :authenticated_root
    #   end
    #
    #   authenticated :user, lambda {|u| u.role == "admin"} do
    #     root to: "admin/dashboard#show", as: :user_root
    #   end
    #
    #   root to: 'landing#show'
    #
    def authenticated(scope=nil, block=nil)
      constraints_for(:authenticate?, scope, block) do
        yield
      end
    end

    # Allow you to route based on whether a scope is *not* authenticated.
    # You can optionally specify which scope.
    #
    #   unauthenticated do
    #     as :user do
    #       root to: 'ants_admin/registrations#new'
    #     end
    #   end
    #
    #   root to: 'dashboard#show'
    #
    def unauthenticated(scope=nil)
      constraint = lambda do |request|
        not request.env["warden"].authenticate? scope: scope
      end

      constraints(constraint) do
        yield
      end
    end

    # Sets the ants_admin scope to be used in the controller. If you have custom routes,
    # you are required to call this method (also aliased as :as) in order to specify
    # to which controller it is targetted.
    #
    #   as :user do
    #     get "sign_in", to: "ants_admin/sessions#new"
    #   end
    #
    # Notice you cannot have two scopes mapping to the same URL. And remember, if
    # you try to access a ants_admin controller without specifying a scope, it will
    # raise ActionNotFound error.
    #
    # Also be aware of that 'ants_admin_scope' and 'as' use the singular form of the
    # noun where other ants_admin route commands expect the plural form. This would be a
    # good and working example.
    #
    #  ants_admin_scope :user do
    #    get "/some/route" => "some_ants_admin_controller"
    #  end
    #  ants_admin_for :users
    #
    # Notice and be aware of the differences above between :user and :users
    def ants_admin_scope(scope)
      constraint = lambda do |request|
        request.env["ants_admin.mapping"] = AntsAdmin.mappings[scope]
        true
      end

      constraints(constraint) do
        yield
      end
    end
    alias :as :ants_admin_scope

    protected

      def ants_admin_session(mapping, controllers) #:nodoc:
        resource :session, only: [], controller: controllers[:sessions], path: "" do
          get   :new,     path: mapping.path_names[:sign_in],  as: "new"
          post  :create,  path: mapping.path_names[:sign_in]
          match :destroy, path: mapping.path_names[:sign_out], as: "destroy", via: mapping.sign_out_via
        end
      end

      def ants_admin_password(mapping, controllers) #:nodoc:
        resource :password, only: [:new, :create, :edit, :update],
          path: mapping.path_names[:password], controller: controllers[:passwords]
      end

      def ants_admin_confirmation(mapping, controllers) #:nodoc:
        resource :confirmation, only: [:new, :create, :show],
          path: mapping.path_names[:confirmation], controller: controllers[:confirmations]
      end

      def ants_admin_unlock(mapping, controllers) #:nodoc:
        if mapping.to.unlock_strategy_enabled?(:email)
          resource :unlock, only: [:new, :create, :show],
            path: mapping.path_names[:unlock], controller: controllers[:unlocks]
        end
      end

      def ants_admin_registration(mapping, controllers) #:nodoc:
        path_names = {
          new: mapping.path_names[:sign_up],
          edit: mapping.path_names[:edit],
          cancel: mapping.path_names[:cancel]
        }

        options = {
          only: [:new, :create, :edit, :update, :destroy],
          path: mapping.path_names[:registration],
          path_names: path_names,
          controller: controllers[:registrations]
        }

        resource :registration, options do
          get :cancel
        end
      end

      def ants_admin_omniauth_callback(mapping, controllers) #:nodoc:
        if mapping.fullpath =~ /:[a-zA-Z_]/
          raise <<-ERROR
AntsAdmin does not support scoping omniauth callbacks under a dynamic segment
and you have set #{mapping.fullpath.inspect}. You can work around by passing
`skip: :omniauth_callbacks` and manually defining the routes. Here is an example:

    match "/users/auth/:provider",
      constraints: { provider: /google|facebook/ },
      to: "ants_admin/omniauth_callbacks#passthru",
      as: :omniauth_authorize,
      via: [:get, :post]

    match "/users/auth/:action/callback",
      constraints: { action: /google|facebook/ },
      to: "ants_admin/omniauth_callbacks",
      as: :omniauth_callback,
      via: [:get, :post]
ERROR
        end

        path, @scope[:path] = @scope[:path], nil
        path_prefix = AntsAdmin.omniauth_path_prefix || "/#{mapping.fullpath}/auth".squeeze("/")

        set_omniauth_path_prefix!(path_prefix)

        providers = Regexp.union(mapping.to.omniauth_providers.map(&:to_s))

        match "#{path_prefix}/:provider",
          constraints: { provider: providers },
          to: "#{controllers[:omniauth_callbacks]}#passthru",
          as: :omniauth_authorize,
          via: [:get, :post]

        match "#{path_prefix}/:action/callback",
          constraints: { action: providers },
          to: controllers[:omniauth_callbacks],
          as: :omniauth_callback,
          via: [:get, :post]
      ensure
        @scope[:path] = path
      end

      DEVISE_SCOPE_KEYS = [:as, :path, :module, :constraints, :defaults, :options]

      def with_ants_admin_exclusive_scope(new_path, new_as, options) #:nodoc:
        old = {}
        DEVISE_SCOPE_KEYS.each { |k| old[k] = @scope[k] }

        new = { as: new_as, path: new_path, module: nil }
        new.merge!(options.slice(:constraints, :defaults, :options))

        @scope.merge!(new)
        yield
      ensure
        @scope.merge!(old)
      end

      def constraints_for(method_to_apply, scope=nil, block=nil)
        constraint = lambda do |request|
          request.env['warden'].send(method_to_apply, scope: scope) &&
            (block.nil? || block.call(request.env["warden"].user(scope)))
        end

        constraints(constraint) do
          yield
        end
      end

      def set_omniauth_path_prefix!(path_prefix) #:nodoc:
        if ::OmniAuth.config.path_prefix && ::OmniAuth.config.path_prefix != path_prefix
          raise "Wrong OmniAuth configuration. If you are getting this exception, it means that either:\n\n" \
            "1) You are manually setting OmniAuth.config.path_prefix and it doesn't match the AntsAdmin one\n" \
            "2) You are setting :omniauthable in more than one model\n" \
            "3) You changed your AntsAdmin routes/OmniAuth setting and haven't restarted your server"
        else
          ::OmniAuth.config.path_prefix = path_prefix
        end
      end

      def raise_no_secret_key #:nodoc:
        raise <<-ERROR
AntsAdmin.secret_key was not set. Please add the following to your AntsAdmin initializer:

  config.secret_key = '#{SecureRandom.hex(64)}'

Please ensure you restarted your application after installing AntsAdmin or setting the key.
ERROR
      end

      def raise_no_ants_admin_method_error!(klass) #:nodoc:
        raise "#{klass} does not respond to 'ants_admin' method. This usually means you haven't " \
          "loaded your ORM file or it's being loaded too late. To fix it, be sure to require 'ants_admin/orm/YOUR_ORM' " \
          "inside 'config/initializers/ants_admin.rb' or before your application definition in 'config/application.rb'"
      end
  end
end
