# frozen_string_literal: true

module Decidim
  module Privacy
    module CreateRegistrationExtensions
      extend ActiveSupport::Concern

      included do
        private

        # We are forcing the unscoped User, otherwise it tries to find the
        # record inside the default_scope users, and fails.
        def create_user
          @user = User.unscoped do
            User.create!(
              email: form.email,
              name: form.name,
              nickname: form.nickname,
              password: form.password,
              password_confirmation: form.password_confirmation,
              organization: form.current_organization,
              tos_agreement: form.tos_agreement,
              newsletter_notifications_at: form.newsletter_at,
              accepted_tos_version: form.current_organization.tos_version,
              locale: form.current_locale
            )
          end
        end
      end
    end
  end
end
