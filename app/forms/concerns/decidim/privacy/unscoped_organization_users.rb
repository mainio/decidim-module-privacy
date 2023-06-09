# frozen_string_literal: true

module Decidim
  module Privacy
    module UnscopedOrganizationUsers
      extend ActiveSupport::Concern

      included do
        def user
          @user ||= current_organization.users.entire_collection.find_by(id: user_id)
        end
      end
    end
  end
end
