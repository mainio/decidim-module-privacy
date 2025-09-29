# frozen_string_literal: true

module Decidim
  module Privacy
    module ApplicationControllerExtensions
      extend ActiveSupport::Concern

      included do
        before_action :privacy_modal_snippets, :privacy_javascript
      end

      private

      def privacy_javascript
        return unless current_user && !current_user.public?

        snippets.add(:foot, view_context.javascript_pack_tag("decidim_account_publish_handler"))
      end

      def privacy_modal_snippets
        return unless respond_to?(:snippets)

        return if anonymous_user?
        return unless user_signed_in?

        snippets.add(:foot, helpers.cell("decidim/privacy/anonymity_modal", current_user)) if Decidim::Privacy.anonymity_enabled && current_user.anonymity.nil?

        snippets.add(:foot, helpers.cell("decidim/privacy/publish_account_modal", current_user)) if current_user && !current_user.public? && user_signed_in?
      end

      def anonymous_user?
        Decidim::Privacy.anonymity_enabled && (current_user && current_user.anonymous?)
      end
    end
  end
end
