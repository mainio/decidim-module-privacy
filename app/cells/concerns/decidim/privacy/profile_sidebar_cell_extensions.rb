# frozen_string_literal: true

module Decidim
  module Privacy
    module ProfileSidebarCellExtensions
      extend ActiveSupport::Concern

      included do
        def can_join_user_group?
          return false unless current_user
          return false unless current_user.public?
          return false if model.is_a?(Decidim::User)

          Decidim::UserGroupMembership.where(user: current_user, user_group: model).empty?
        end
      end
    end
  end
end
