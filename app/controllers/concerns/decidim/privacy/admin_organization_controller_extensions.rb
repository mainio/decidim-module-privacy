# frozen_string_literal: true

module Decidim
  module Privacy
    module AdminOrganizationControllerExtensions
      extend ActiveSupport::Concern
      included do
        def users
          search(current_organization.users.unscoped.available)
        end
      end
    end
  end
end
