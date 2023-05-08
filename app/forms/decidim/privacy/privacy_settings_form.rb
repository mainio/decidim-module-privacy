# frozen_string_literal: true

module Decidim
  module Privacy
    class PrivacySettingsForm < Form
      mimic :user

      attribute :published_at, Boolean
      attribute :allow_private_messaging, Boolean

      def map_model(user)
        self.published_at = user.published_at.present?
        self.allow_private_messaging = user.allow_private_messaging
      end
    end
  end
end
