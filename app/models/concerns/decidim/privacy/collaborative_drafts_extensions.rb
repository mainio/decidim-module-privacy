# frozen_string_literal: true

module Decidim
  module Privacy
    module CollaborativeDraftsExtensions
      extend ActiveSupport::Concern

      included do
        # This is overridden in order to maintain the same functionality for
        # collaborative drafts and proposals. We should investigate this further
        # if it would be possible to fix the inconsistency between proposals and
        # collaborative drafts.
        #
        # For further details, see the Asana task.
        def editable_by?(user)
          user.public? && authored_by?(user)
        end
      end
    end
  end
end
