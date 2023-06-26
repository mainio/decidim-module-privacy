# frozen_string_literal: true

module Decidim
  module Privacy
    module ConversationExtensions
      extend ActiveSupport::Concern

      included do
        has_many :participants, -> { entire_collection }, through: :participations
      end
    end
  end
end
