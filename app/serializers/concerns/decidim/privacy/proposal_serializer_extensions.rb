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
      end
    end
  end
end
