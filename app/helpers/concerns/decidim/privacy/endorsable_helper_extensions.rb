# frozen_string_literal: true

module Decidim
  module Privacy
    module EndorsableHelperExtensions
      extend ActiveSupport::Concern

      included do
        def endorsements_enabled?
          current_settings.endorsements_enabled && current_user&.public?
        end
      end
    end
  end
end
