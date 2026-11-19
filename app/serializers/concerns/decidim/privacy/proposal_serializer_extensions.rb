# frozen_string_literal: true

module Decidim
  module Privacy
    module ProposalSerializerExtensions
      extend ActiveSupport::Concern

      included do
        private

        def user_likes
          proposal.likes.for_listing.map do |identity|
            if identity.normalized_author.is_a?(Decidim::User) && identity.normalized_author.published_at.nil?
              private = Decidim::Privacy::PrivateUser.new

              private.name
            else
              identity.normalized_author&.name
            end
          end
        end

        def author_name(author)
          if author.deleted?
            ""
          elsif author.respond_to?(:name)
            translated_attribute(author.name) # is a Decidim::User or Decidim::Organization
          elsif author.respond_to?(:title)
            translated_attribute(author.title) # is a Decidim::Meetings::Meeting
          end
        end

        def author_url(author)
          if author.deleted?
            ""
          elsif author.respond_to?(:nickname)
            profile_url(author) # is a Decidim::User
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
