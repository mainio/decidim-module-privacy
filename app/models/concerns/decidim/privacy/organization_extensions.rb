# frozen_string_literal: true

module Decidim
  module Privacy
    module OrganizationExtensions
      extend ActiveSupport::Concern

      included do
        has_many :admins, -> { entire_collection.where(admin: true) }, foreign_key: "decidim_organization_id", class_name: "Decidim::User", dependent: :destroy
        has_many :users_with_any_role, -> { entire_collection.where.not(roles: []) }, foreign_key: "decidim_organization_id", class_name: "Decidim::User", dependent: :destroy
      end
    end
  end
end
