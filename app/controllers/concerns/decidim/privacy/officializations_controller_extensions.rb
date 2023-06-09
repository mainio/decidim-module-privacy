# frozen_string_literal: true

module Decidim
  module Privacy
    module OfficializationsControllerExtensions
      extend ActiveSupport::Concern
      included do
        private

        def collection
          @collection ||= current_organization.users.entire_collection.not_deleted.left_outer_joins(:user_moderation)
        end
      end
    end
  end
end
