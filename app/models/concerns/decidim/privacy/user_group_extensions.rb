# frozen_string_literal: true

module Decidim
  module Privacy
    module UserGroupExtensions
      extend ActiveSupport::Concern

      included do
        default_scope { visible }

        scope :visible, -> { confirmed.where.not("extended_data->>'verified_at' IS ?", nil) }

        def public?
          true
        end

        searchable_fields(
          {
            organization_id: :decidim_organization_id,
            A: :name,
            datetime: :created_at
          },
          index_on_create: ->(user_group) { !user_group.deleted? && user_group.verified? },
          index_on_update: ->(user_group) { !user_group.deleted? && user_group.verified? }
        )

        def possible_members
          memberships
            .where.not(decidim_users: { published_at: nil })
            .where(decidim_users: { deleted_at: nil })
        end
      end
    end
  end
end
