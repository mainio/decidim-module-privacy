# frozen_string_literal: true

module Decidim
  module Core
    # A resolver for the GraphQL users/groups endpoints
    # Used in the keyword "users", ie:
    #
    # users(filter: {nickname: "foo"}) {
    #   name
    # }
    #
    class UserEntityList
      include NeedsApiFilterAndOrder

      def initialize
        @model_class = Decidim::UserBaseEntity
      end

      def call(obj, args, ctx)
        @query = if obj.is_a?(Decidim::UserGroup)
                   Decidim::UserBaseEntity
                     .where(organization: ctx[:current_organization])
                     .confirmed
                     .not_blocked
                     .includes(avatar_attachment: :blob)
                 else
                   Decidim::UserBaseEntity
                     .where(organization: ctx[:current_organization])
                     .where.not(published_at: nil)
                     .confirmed
                     .not_blocked
                     .includes(avatar_attachment: :blob)
                 end
        add_filter_keys(args[:filter])
        add_order_keys(args[:order].to_h)
        @query
      end
    end
  end
end
