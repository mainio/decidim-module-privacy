# frozen_string_literal: true

module Decidim
  module Privacy
    module UserGroupPendingRequestsListCellExtensions
      extend ActiveSupport::Concern

      included do
        def requests
          @requests ||= model.possible_members.includes(:user).where(role: "requested")
        end
      end
    end
  end
end
