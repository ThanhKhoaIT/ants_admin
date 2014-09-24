require 'ants_admin/omniauth'

module AntsAdmin
  module Models
    # Adds OmniAuth support to your model.
    #
    # == Options
    #
    # Oauthable adds the following options to ants_admin_for:
    #
    #   * +omniauth_providers+: Which providers are available to this model. It expects an array:
    #
    #       ants_admin_for :database_authenticatable, :omniauthable, omniauth_providers: [:twitter]
    #
    module Omniauthable
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        []
      end

      module ClassMethods
        AntsAdmin::Models.config(self, :omniauth_providers)
      end
    end
  end
end
