module AntsAdmin
  module Hooks
    # A small warden proxy so we can remember, forget and
    # sign out users from hooks.
    class Proxy #:nodoc:
      include AntsAdmin::Controllers::Rememberable
      include AntsAdmin::Controllers::SignInOut

      attr_reader :warden
      delegate :cookies, :env, to: :warden

      def initialize(warden)
        @warden = warden
      end

      def session
        warden.request.session
      end
    end
  end
end