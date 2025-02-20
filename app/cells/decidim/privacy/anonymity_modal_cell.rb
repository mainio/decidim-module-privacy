# frozen_string_literal: true

module Decidim
  module Privacy
    class AnonymityModalCell < Decidim::ViewModel
      delegate :decidim_privacy, to: :controller
    end
  end
end
