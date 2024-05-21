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

        def user
          @user ||= Decidim::User.entire_collection.find_by(
            id: params[:user_id],
            organization: current_organization
          )
        end
      end
    end
  end
end
