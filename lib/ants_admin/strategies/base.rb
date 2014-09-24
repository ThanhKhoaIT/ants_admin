module AntsAdmin
  module Strategies
    # Base strategy for AntsAdmin. Responsible for verifying correct scope and mapping.
    class Base < ::Warden::Strategies::Base
      # Whenever CSRF cannot be verified, we turn off any kind of storage
      def store?
        !env["ants_admin.skip_storage"]
      end

      # Checks if a valid scope was given for ants_admin and find mapping based on this scope.
      def mapping
        @mapping ||= begin
          mapping = AntsAdmin.mappings[scope]
          raise "Could not find mapping for #{scope}" unless mapping
          mapping
        end
      end
    end
  end
end
