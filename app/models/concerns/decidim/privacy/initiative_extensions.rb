# frozen_string_literal: true

module Decidim
  module Privacy
    module InitiativeExtensions
      extend ActiveSupport::Concern

      included do
        def author_users
          [author].concat(committee_members.excluding_author.map(&:user))

          authors = []

          [author].each do |author|
            organization ||= author.organization
            if !author.nil? && author.published_at.present?
              authors.push(author)
            else
              authors.push(
                Decidim::Privacy::PrivateUser.new(
                  id: 0,
                  name: "Anonymous",
                  organization: organization
                )
              )
            end
          end

          authors
        end

        def has_authorship?(user)
          return true if decidim_author_id == user.id

          committee_members.approved.where(decidim_users_id: user.id).any?
        end

        def author_name
          user_group&.name || author&.name
        end
      end
    end
  end
end
