# frozen_string_literal: true

module Decidim
  module Privacy
    module ModeratedUsersControllerExtensions
      extend ActiveSupport::Concern

      included do
        private

        def base_query_finder
          UserModeration.joins(:user).entire_collection.where(decidim_users: { decidim_organization_id: current_organization.id })
        end
      end
    end
  end
end
