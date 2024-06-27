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

        snippets.add(:foot, helpers.cell("decidim/privacy/publish_account_modal", current_user)) if current_user && !current_user.public? && user_signed_in?
      end
    end
  end
end
