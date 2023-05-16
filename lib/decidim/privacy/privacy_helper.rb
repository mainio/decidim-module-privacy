# frozen_string_literal: true

module Decidim
  module Privacy
    module PrivacyHelper
      def public_account?
        return false unless current_user

        current_user.published_at.present?
      end

      def ensure_public_account
        return true if public_account?

        flash[:notice] = t("decidim.privacy.publish_account.unauthorized")

        redirect_back(fallback_location: decidim.root_path)
      end
    end
  end
end
