# frozen_string_literal: true

module Decidim
  module Privacy
    # Fixes the following bug in the core:
    # https://github.com/decidim/decidim/pull/12458
    #
    # TODO: Remove after the fix is released.
    module ImpersonatableUsersControllerExtensions
      extend ActiveSupport::Concern

      included do
        private

        def collection
          @collection ||= current_organization.users.entire_collection.not_deleted.where(admin: false, roles: [])
        end
      end
    end
  end
end
