# frozen_string_literal: true

module Decidim
  module Privacy
    # Modal that displays the controls to make the profile public.
    class AnonymityModalCell < Decidim::ViewModel
      delegate :decidim_privacy, to: :controller
    end
  end
end
