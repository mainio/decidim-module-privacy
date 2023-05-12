# frozen_string_literal: true

module Decidim
  module Privacy
    module PrivacyHelper
      def public_account?
        return false unless current_user

        current_user.published_at.present?
      end
    end
  end
end
