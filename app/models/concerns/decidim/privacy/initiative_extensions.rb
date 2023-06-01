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
            if author.published_at.present?
              authors.push(author)
            else
              authors.push(Decidim::Privacy::PrivateUser.new)
            end
          end

          authors
        end
      end
    end
  end
end
