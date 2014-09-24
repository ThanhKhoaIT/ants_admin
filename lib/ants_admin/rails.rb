require 'ants_admin/rails/routes'
require 'ants_admin/rails/warden_compat'

module AntsAdmin
  class Engine < ::Rails::Engine
    config.ants_admin = AntsAdmin

    # Initialize Warden and copy its configurations.
    config.app_middleware.use Warden::Manager do |config|
      AntsAdmin.warden_config = config
    end

    # Force routes to be loaded if we are doing any eager load.
    config.before_eager_load { |app| app.reload_routes! }

    initializer "ants_admin.url_helpers" do
      AntsAdmin.include_helpers(AntsAdmin::Controllers)
    end

    initializer "ants_admin.omniauth" do |app|
      AntsAdmin.omniauth_configs.each do |provider, config|
        app.middleware.use config.strategy_class, *config.args do |strategy|
          config.strategy = strategy
        end
      end

      if AntsAdmin.omniauth_configs.any?
        AntsAdmin.include_helpers(AntsAdmin::OmniAuth)
      end
    end

    initializer "ants_admin.secret_key" do |app|
      if app.respond_to?(:secrets)
        AntsAdmin.secret_key ||= app.secrets.secret_key_base
      elsif app.config.respond_to?(:secret_key_base)
        AntsAdmin.secret_key ||= app.config.secret_key_base
      end

      AntsAdmin.token_generator ||=
        if secret_key = AntsAdmin.secret_key
          AntsAdmin::TokenGenerator.new(
            AntsAdmin::CachingKeyGenerator.new(AntsAdmin::KeyGenerator.new(secret_key))
          )
        end
    end

    initializer "ants_admin.fix_routes_proxy_missing_respond_to_bug" do
      # Deprecate: Remove once we move to Rails 4 only.
      ActionDispatch::Routing::RoutesProxy.class_eval do
        def respond_to?(method, include_private = false)
          super || routes.url_helpers.respond_to?(method)
        end
      end
    end
  end
end
