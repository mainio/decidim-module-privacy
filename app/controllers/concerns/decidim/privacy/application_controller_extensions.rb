# frozen_string_literal: true

module Decidim
  module Privacy
    module ApplicationControllerExtensions
      extend ActiveSupport::Concern

      included do
        before_action :privacy_modal_snippets
      end

      private

      def privacy_modal_snippets
        return unless respond_to?(:snippets)
        return if current_user && current_user.public?

        snippets.add(:foot, helpers.javascript_pack_tag("decidim_account_publish_handler"))
        return unless user_signed_in?

        snippets.add(:foot, helpers.cell("decidim/privacy/publish_account_modal", current_user))
      end
    end
  end
end
