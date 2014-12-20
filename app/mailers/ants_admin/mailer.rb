# if defined?(ActionMailer)
#   class AntsAdmin::Mailer < AntsAdmin.parent_mailer.constantize
#     include AntsAdmin::Mailers::Helpers
#
#     def confirmation_instructions(record, token, opts={})
#       @token = token
#       ants_admin_mail(record, :confirmation_instructions, opts)
#     end
#
#     def reset_password_instructions(record, token, opts={})
#       @token = token
#       ants_admin_mail(record, :reset_password_instructions, opts)
#     end
#
#     def unlock_instructions(record, token, opts={})
#       @token = token
#       ants_admin_mail(record, :unlock_instructions, opts)
#     end
#   end
# end
