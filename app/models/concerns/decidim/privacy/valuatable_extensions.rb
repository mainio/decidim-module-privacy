# frozen_string_literal: true

module Decidim
  module Privacy
    module ValuatableExtensions
      include ActiveSupport::Concern
      included do
        def valuators
          valuator_role_ids = valuation_assignments.where(proposal: self).pluck(:valuator_role_id)
          user_ids = participatory_space.user_roles(:valuator).where(id: valuator_role_ids).pluck(:decidim_user_id)
          participatory_space.organization.users.entire_collection.where(id: user_ids)
        end
      end
    end
  end
end
