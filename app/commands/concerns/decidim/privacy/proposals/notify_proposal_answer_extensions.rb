# frozen_string_literal: true

module Decidim
  module Privacy
    module Proposals
      module NotifyProposalAnswerExtensions
        extend ActiveSupport::Concern

        included do
          def increment_score
            if proposal.accepted?
              proposal.coauthorships.find_each do |coauthorship|
                Decidim::Gamification.increment_score(coauthorship.user_group || coauthorship.private_author, :accepted_proposals)
              end
            elsif initial_state == "accepted"
              proposal.coauthorships.find_each do |coauthorship|
                Decidim::Gamification.decrement_score(coauthorship.user_group || coauthorship.private_author, :accepted_proposals)
              end
            end
          end
        end
      end
    end
  end
end
