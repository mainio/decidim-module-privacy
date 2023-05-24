# frozen_string_literal: true

module Decidim
  module Privacy
    module OrganizationExtensions
      extend ActiveSupport::Concern

      included do
        has_many :admins, -> { unscope(where: :published_at).where(admin: true) }, foreign_key: "decidim_organization_id", class_name: "Decidim::User", dependent: :destroy
      end
    end
  end
end
