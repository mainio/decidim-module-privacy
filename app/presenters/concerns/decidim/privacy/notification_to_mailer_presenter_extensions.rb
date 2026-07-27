# frozen_string_literal: true

module Decidim
  module Privacy
    module NotificationToMailerPresenterExtensions
      extend ActiveSupport::Concern

      included do
        def resource_url
          return if hide_resource_link?

          return if user.nil?

          url_helpers.profile_badges_url(
            nickname: user.nickname,
            host: user.organization.host
          )
        end

        def resource_path
          return if hide_resource_link?

          return if user.nil?

          url_helpers.profile_badges_path(nickname: user.nickname)
        end

        private

        def hide_resource_link?
          resource.is_a?(Decidim::UserBaseEntity) && (!resource.public? || resource.anonymous?)
        end
      end
    end
  end
end
