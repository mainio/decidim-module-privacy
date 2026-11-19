# frozen_string_literal: true

module Decidim
  module Privacy
    module Proposals
      module PublishProposalExtensions
        extend ActiveSupport::Concern

        included do
          def increment_scores
            @proposal.coauthorships.find_each do |coauthorship|
              Decidim::Gamification.increment_score(coauthorship.private_author, :proposals)
            end
          end
        end
      end
    end
  end
end
