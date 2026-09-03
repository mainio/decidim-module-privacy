# frozen_string_literal: true

module Decidim
  module Privacy
    module AmendmentExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :amender, -> { entire_collection }, foreign_key: "decidim_user_id", class_name: "Decidim::User"
      end
    end
  end
end
