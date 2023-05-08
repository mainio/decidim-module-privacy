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
        user.published_at = Time.current if form.published_at
        user.allow_private_messaging = form.allow_private_messaging
        user.direct_message_types = form.direct_message_types
      end
    end
  end
end
