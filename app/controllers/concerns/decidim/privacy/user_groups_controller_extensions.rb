# frozen_string_literal: true

module Decidim
  module Privacy
    module UserGroupsControllerExtensions
      extend ActiveSupport::Concern

      included do
        private

        def collection
          UserGroup
            .entire_collection
            .left_outer_joins(:memberships)
            .select("decidim_users.*, COUNT(decidim_user_group_memberships.decidim_user_group_id) as users_count")
            .where(decidim_user_group_memberships: { decidim_user_id: current_organization.users })
            .group(Arel.sql("decidim_users.id"))
        end
      end
    end
  end
end
