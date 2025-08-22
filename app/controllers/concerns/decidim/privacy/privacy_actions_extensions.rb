# frozen_string_literal: true

module Decidim
  module Privacy
    class ActionForbidden < ::Decidim::ActionForbidden; end

    # This is the concern that adds publicity checks to the included controllers
    module PrivacyActionsExtensions
      extend ActiveSupport::Concern

      included do
        helper_method :public_action?, :allowed_participation_to?

        rescue_from Decidim::Privacy::ActionForbidden, with: :user_is_not_public

        def enforce_permission_to(action, subject, extra_context = {})
          super

          raise ActionForbidden unless allowed_participation_to?(action)
        end
      end

      def allowed_participation_to?(action)
        return true unless user_signed_in?
        return true unless public_action?(action)
        return true if current_user.anonymous?

        current_user.public?
      end

      def public_action?(action)
        return false unless respond_to?(:public_actions, true)

        public_actions.include?(action)
      end

      private

      def user_is_not_public
        return true if current_user&.public?

        render "decidim/privacy/privacy_block"
      end

      def public_actions
        [:create, :edit, :update]
      end
    end
  end
end
