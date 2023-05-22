# frozen_string_literal: true

module Decidim
  module Privacy
    # This is the concern that adds publicity checks to the included controllers
    module PrivacyActionsExtensions
      extend ActiveSupport::Concern

      included do
        before_action :ensure_public_account!, only: [:new, :create, :update, :publish, :complete]
      end

      private

      def ensure_public_account!
        return true if current_user&.public?

        flash[:notice] = t("decidim.privacy.publish_account.unauthorized")

        render "decidim/privacy/privacy_block"
      end
    end
  end
end
