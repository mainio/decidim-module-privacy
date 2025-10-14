# frozen_string_literal: true

module Decidim
  module Privacy
    module CommentExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :author, -> { entire_collection }, polymorphic: true, foreign_key: "decidim_author_id", foreign_type: "decidim_author_type"
      end
    end
  end
end
