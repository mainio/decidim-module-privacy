# frozen_string_literal: true

module Decidim
  module Privacy
    module LikeableHelperExtensions
      extend ActiveSupport::Concern

      included do
        def likes_enabled?
          current_settings.likes_enabled && (current_user&.public? || (Decidim::Privacy.anonymity_enabled && current_user&.anonymous?))
        end

        def show_likes_card?
          current_user.present?
        end
      end
    end
  end
end
