# frozen_string_literal: true

module Decidim
  module Privacy
    module NewsletterExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :author, -> { entire_collection }, foreign_key: :author_id, class_name: "Decidim::User"
      end
    end
  end
end
