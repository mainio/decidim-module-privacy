# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Privacy
    module EndorsersListCellExtensions
      extend ActiveSupport::Concern

      included do
        def visible_endorsers
          @visible_endorsers ||= if voted_by_me?
                                   other_endorsers = base_relation.where.not(author: current_user).limit(Decidim::EndorsersListCell::MAX_ITEMS_STACKED - 1).map do |identity|
                                     present(identity.normalized_author)
                                   end

                                   other_endorsers + [present(current_user)]
                                 else
                                   base_relation.limit(Decidim::EndorsersListCell::MAX_ITEMS_STACKED).map { |identity| present(identity.normalized_author) }
                                 end
        end
      end
    end
  end
end
