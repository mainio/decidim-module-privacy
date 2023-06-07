# frozen_string_literal: true

module Decidim
  module Privacy
    module ImpersonatableUsersControllerExtensions
      extend ActiveSupport::Concern
      included do
        private

        def collection
          @collection ||= current_organization.users.entire_collection.where(admin: false, roles: [])
        end
      end
    end
  end
end
