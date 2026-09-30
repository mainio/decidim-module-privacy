# frozen_string_literal: true

module Decidim
  module Privacy
    module EndorsementExtensions
      extend ActiveSupport::Concern

      included do
        scope :with_visible_authors, lambda {
          where(decidim_author_id: Decidim::UserBaseEntity.select(:id))
        }

        default_scope { with_visible_authors }
      end
    end
  end
end
