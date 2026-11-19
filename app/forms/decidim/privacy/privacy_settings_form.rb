# frozen_string_literal: true

module Decidim
  module Privacy
    class PrivacySettingsForm < Form
      mimic :user

      attribute :anonymity, Boolean
      attribute :published_at, Boolean
      attribute :allow_private_messaging, Boolean
      attribute :allow_public_contact, Boolean

      def map_model(user)
        self.anonymity = user.anonymity
        self.published_at = user.published_at.present?
        self.allow_private_messaging = user.allow_private_messaging
        self.allow_public_contact = user.direct_message_types == "all"
      end

      def direct_message_types
        allow_public_contact ? "all" : "followed-only"
      end
    end
  end
end
