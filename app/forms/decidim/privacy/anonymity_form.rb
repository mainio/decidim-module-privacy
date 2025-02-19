# frozen_string_literal: true

module Decidim
  module Privacy
    class AnonymityForm < Form
      attribute :agree_anonymous

      validates :agree_anonymous, allow_nil: false, acceptance: true
    end
  end
end
