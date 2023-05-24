# frozen_string_literal: true

module Decidim
  module Privacy
    module UserExtensions
      extend ActiveSupport::Concern
      included do
        default_scope { where.not(published_at: nil) }
        # we need to remove the default scope for the registeration, so as to check the uniqueness of
        # accounts through all of the accounts
        def self.find_for_authentication(warden_conditions)
          organization = warden_conditions.dig(:env, "decidim.current_organization")
          unscoped.find_by(
            email: warden_conditions[:email].to_s.downcase,
            decidim_organization_id: organization.id
          )
        end

        def public?
          published_at.present?
        end
      end
    end
  end
end
