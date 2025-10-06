# frozen_string_literal: true

module Decidim
  module Privacy
    module BaseEventExtensions
      extend ActiveSupport::Concern

      included do
        def resource_path
          return if user.nil?

          url_helpers.profile_badges_path(nickname: user.nickname)
        end

        def resource_url
          return if user.nil?

          url_helpers.profile_badges_url(
            nickname: user.nickname,
            host: user.organization.host
          )
        end
      end
    end
  end
end
