# frozen_string_literal: true

module Decidim
  module Privacy
    module ActionLogExtensions
      extend ActiveSupport::Concern

      included do
        # In case the resource happens to be a user, it has to be unscoped for
        # the resource to be found. Otherwise when trying to save such ActionLog
        # record, the validations would fail.

        def resource
          return super unless ["Decidim::UserGroup", "Decidim::User", "Decidim::UserBaseEntity"].include?(resource_type)

          Decidim::UserGroup.entire_collection.find_by(id: resource_id)
        end
      end
    end
  end
end
