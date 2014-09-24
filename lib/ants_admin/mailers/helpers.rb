module AntsAdmin
  module Mailers
    module Helpers
      extend ActiveSupport::Concern

      included do
        include AntsAdmin::Controllers::ScopedViews
        attr_reader :scope_name, :resource
      end

      protected

      # Configure default email options
      def ants_admin_mail(record, action, opts={})
        initialize_from_record(record)
        mail headers_for(action, opts)
      end

      def initialize_from_record(record)
        @scope_name = AntsAdmin::Mapping.find_scope!(record)
        @resource   = instance_variable_set("@#{ants_admin_mapping.name}", record)
      end

      def ants_admin_mapping
        @ants_admin_mapping ||= AntsAdmin.mappings[scope_name]
      end

      def headers_for(action, opts)
        headers = {
          subject: subject_for(action),
          to: resource.email,
          from: mailer_sender(ants_admin_mapping),
          reply_to: mailer_reply_to(ants_admin_mapping),
          template_path: template_paths,
          template_name: action
        }.merge(opts)

        @email = headers[:to]
        headers
      end

      def mailer_reply_to(mapping)
        mailer_sender(mapping, :reply_to)
      end

      def mailer_from(mapping)
        mailer_sender(mapping, :from)
      end

      def mailer_sender(mapping, sender = :from)
        default_sender = default_params[sender]
        if default_sender.present?
          default_sender.respond_to?(:to_proc) ? instance_eval(&default_sender) : default_sender
        elsif AntsAdmin.mailer_sender.is_a?(Proc)
          AntsAdmin.mailer_sender.call(mapping.name)
        else
          AntsAdmin.mailer_sender
        end
      end

      def template_paths
        template_path = _prefixes.dup
        template_path.unshift "#{@ants_admin_mapping.scoped_path}/mailer" if self.class.scoped_views?
        template_path
      end

      # Setup a subject doing an I18n lookup. At first, it attempts to set a subject
      # based on the current mapping:
      #
      #   en:
      #     ants_admin:
      #       mailer:
      #         confirmation_instructions:
      #           user_subject: '...'
      #
      # If one does not exist, it fallbacks to ActionMailer default:
      #
      #   en:
      #     ants_admin:
      #       mailer:
      #         confirmation_instructions:
      #           subject: '...'
      #
      def subject_for(key)
        I18n.t(:"#{ants_admin_mapping.name}_subject", scope: [:ants_admin, :mailer, key],
          default: [:subject, key.to_s.humanize])
      end
    end
  end
end
