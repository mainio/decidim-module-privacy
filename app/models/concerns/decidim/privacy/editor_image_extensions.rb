# frozen_string_literal: true

module Decidim
  module Privacy
    module EditorImageExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :author, -> { entire_collection }, foreign_key: :decidim_author_id, class_name: "Decidim::User"
      end
    end
  end
end
