# frozen_string_literal: true

module Decidim
  module Core
    # A resolver for the GraphQL user/group endpoints
    # Used in the keyword "user", ie:
    #
    # user(nickname: "foo") {
    #   name
    # }
    #
    class UserEntityFinder
      def call(obj, args, ctx)
        filters = {
          organization: ctx[:current_organization]
        }
        args.each do |argument, value|
          next if value.blank?

          v = value.to_s
          v = v[1..-1] if value.starts_with? "@"
          filters[argument.to_sym] = v
        end
        if obj.is_a?(Decidim::UserGroup)
          Decidim::UserBaseEntity
            .confirmed
            .not_blocked
            .find_by(filters)
        else
          Decidim::UserBaseEntity
            .confirmed
            .where.not(published_at: nil)
            .not_blocked
            .find_by(filters)
        end
      end
    end
  end
end
