# frozen_string_literal: true

module Decidim
  module Privacy
    module UserPresenterExtensions
      extend ActiveSupport::Concern

      included do
        def nickname
          return "" if __getobj__.nil?
          return "" if __getobj__.blocked?
          return "" unless public_user?

          "@#{__getobj__.nickname}"
        end

        def profile_url
          return "" unless respond_to?(:public?) && public?
          return "" if respond_to?(:deleted?) && deleted?

          decidim.profile_url(__getobj__.nickname)
        end

        def avatar_url(variant = nil)
          return Decidim::AvatarUploader.new(Decidim::User.new, :avatar).default_url if __getobj__.nil?
          return default_avatar_url unless __getobj__.public?
          return default_avatar_url if __getobj__.blocked?
          return default_avatar_url unless avatar.attached?

          avatar.path(variant:)
        end

        def profile_path
          return "" unless public_user?
          return "" if respond_to?(:deleted?) && deleted?

          decidim.profile_path(__getobj__.nickname)
        end

        def name
          return I18n.t("deleted_user", scope: "decidim.components.comment") if respond_to?(:deleted?) && deleted?
          return I18n.t("unnamed_user", scope: "decidim.privacy.private_account") unless public_user?

          super
        end

        private

        def decidim
          @decidim ||= Decidim::EngineRouter.new("decidim", { host: __getobj__.organization.host })
        end

        def public_user?
          object = __getobj__
          return false if object.nil?
          return true if object.is_a?(::Decidim::UserGroup)

          object.published_at.present?
        end
      end
    end
  end
end
