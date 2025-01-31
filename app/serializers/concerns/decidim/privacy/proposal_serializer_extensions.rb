# frozen_string_literal: true

module Decidim
  module Privacy
    module ProposalSerializerExtensions
      extend ActiveSupport::Concern

      included do
        private

        def user_endorsements
          proposal.endorsements.for_listing.map do |identity|
            if identity.normalized_author.is_a?(Decidim::User) && identity.normalized_author.published_at.nil?
              private = Decidim::Privacy::PrivateUser.new

              private.name
            else
              identity.normalized_author&.name
            end
          end
        end

        # Fixes the following bug for the proposal serializer:
        # https://github.com/decidim/decidim/pull/13681
        def author_url(author)
          return "" if author.respond_to?(:deleted?) && author.deleted?

          if author.respond_to?(:nickname)
            profile_url(author.nickname) # is a Decidim::User or Decidim::UserGroup
          elsif author.respond_to?(:title)
            meeting_url(author) # is a Decidim::Meetings::Meeting
          else
            root_url # is a Decidim::Organization
          end
        end
      end
    end
  end
end
