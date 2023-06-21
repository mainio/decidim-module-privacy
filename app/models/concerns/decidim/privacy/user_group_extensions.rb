# frozen_string_literal: true

module Decidim
  module Privacy
    module UserGroupExtensions
      extend ActiveSupport::Concern

      class_methods do
        def unscope_verified_at
          scope = all

          remove_clause = unscoped.unscope(where: :type).where.not("extended_data->>'verified_at' IS ?", nil).where_clause
          scope.where_clause -= remove_clause

          scope
        end
      end

      included do
        default_scope { visible }

        scope :visible, -> { confirmed.where.not("extended_data->>'verified_at' IS ?", nil) }
        scope :entire_collection, -> { unscope_verified_at.unscope(where: :confirmed_at) }

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
