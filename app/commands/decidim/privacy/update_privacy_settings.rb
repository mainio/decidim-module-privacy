# frozen_string_literal: true

module Decidim
  module Privacy
    # Command to update user's privacy settings
    class UpdatePrivacySettings < Decidim::Command
      # Updates a user's privacy settings.
      #
      # user - The user to be updated.
      # form - The form with the data.
      def initialize(user, form)
        @user = user
        @form = form
      end

      def call
        return broadcast(:invalid) unless @form.valid?

        update_privacy_settings
        @user.save!

        broadcast(:ok, @user)
      end

      private

      attr_reader :form, :user

      def update_privacy_settings
        user.anonymity = update_anonymity
        user.published_at = update_published_at
        user.allow_private_messaging = form.allow_private_messaging
        user.direct_message_types = form.direct_message_types
      end

      def update_published_at
        return Time.current if form.published_at

        nil
      end

      def update_anonymity
        return nil if form.published_at == false && form.anonymity == "0"

        form.anonymity
      end
    end
  end
end
