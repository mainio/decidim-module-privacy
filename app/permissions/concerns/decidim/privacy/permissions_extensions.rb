# frozen_string_literal: true

module Decidim
  module Privacy
    module PermissionsExtensions
      extend ActiveSupport::Concern

      included do
        # rubocop:disable Metrics/CyclomaticComplexity
        def amend_action?
          return unless permission_action.subject == :amendment
          return disallow! unless component.settings.amendments_enabled && (user.public? || user.anonymous?)

          case permission_action.action
          when :create
            return allow! if component.current_settings.amendment_creation_enabled
          when :accept,
              :reject
            return allow! if component.current_settings.amendment_reaction_enabled
          when :promote
            return allow! if component.current_settings.amendment_promotion_enabled
          end

          amendment = context.fetch(:amendment, nil)
          toggle_allow(amendment&.amender == user)
        end
        # rubocop:enable Metrics/CyclomaticComplexity
      end
    end
  end
end
