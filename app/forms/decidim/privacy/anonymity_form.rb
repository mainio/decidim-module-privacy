# frozen_string_literal: true

module Decidim
  module Privacy
    class AnonymityForm < Form
      attribute :set_anonymity

      validates :set_anonymity, allow_nil: false, presence: true
    end
  end
end
