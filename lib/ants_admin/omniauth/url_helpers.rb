module AntsAdmin
  module OmniAuth
    module UrlHelpers
      def self.define_helpers(mapping)
      end

      def omniauth_authorize_path(resource_or_scope, *args)
        scope = AntsAdmin::Mapping.find_scope!(resource_or_scope)
        _ants_admin_route_context.send("#{scope}_omniauth_authorize_path", *args)
      end

      def omniauth_callback_path(resource_or_scope, *args)
        scope = AntsAdmin::Mapping.find_scope!(resource_or_scope)
        _ants_admin_route_context.send("#{scope}_omniauth_callback_path", *args)
      end
    end
  end
end
