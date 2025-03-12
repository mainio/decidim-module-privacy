# frozen_string_literal: true

module Decidim
  module Privacy
    module PermissionsExtensions
      extend ActiveSupport::Concern

      included do
        def can_request_access_collaborative_draft?
          return toggle_allow(false) unless collaborative_drafts_enabled? && collaborative_draft.open?
          return toggle_allow(false) if collaborative_draft.requesters.include?(user)
          return toggle_allow(false) unless user.public? || user.anonymous?

          toggle_allow(!collaborative_draft.editable_by?(user))
        end
      end
    end
  end
end
