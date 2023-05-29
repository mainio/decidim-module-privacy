# frozen_string_literal: true

module Decidim
  module Privacy
    module UserPresenterExtensions
      extend ActiveSupport::Concern

      included do
        def nickname
          return "" if __getobj__.blocked?
          return "" unless public_user?

          "@#{__getobj__.nickname}"
        end

        def profile_url
          return "" if respond_to?(:deleted?) && deleted?
          return "" unless public_user?

          decidim.profile_url(__getobj__.nickname)
        end

        def avatar_url(variant = nil)
          return default_avatar_url if __getobj__.blocked?
          return default_avatar_url unless avatar.attached?
          return default_avatar_url unless public_user?

          avatar.path(variant: variant)
        end

        def name
          return I18n.t("unnamed_user", scope: "decidim.privacy.private_account") unless public_user?

          super
        end

        private

        def public_user?
          __getobj__.published_at.nil?
        end
      end
    end
  end
end
