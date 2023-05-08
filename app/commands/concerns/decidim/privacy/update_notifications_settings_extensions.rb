# frozen_string_literal: true

module Decidim
  module Privacy
    module UpdateNotificationsSettingsExtensions
      extend ActiveSupport::Concern

      included do
        private

        # Before merging to the core, we need to over-ride this method, so as to not let the
        # notification_types got updated, while it has been removed from the view. In the fuure versions of
        # decidim, this feature may added to the decdidim core along with other changes.
        def update_notifications_settings
          @user.newsletter_notifications_at = @form.newsletter_notifications_at
          @user.direct_message_types = @form.direct_message_types
          @user.email_on_moderations = @form.email_on_moderations
          @user.notification_settings = @user.notification_settings.merge(@form.notification_settings)
          @user.notifications_sending_frequency = @form.notifications_sending_frequency
        end
      end
    end
  end
end
