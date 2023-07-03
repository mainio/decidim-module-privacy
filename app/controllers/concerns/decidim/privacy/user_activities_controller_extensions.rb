# frozen_string_literal: true

module Decidim
  module Privacy
    module UserActivitiesControllerExtensions
      extend ActiveSupport::Concern

      included do
        def index
          raise ActionController::RoutingError, "Missing user: #{params[:nickname]}" unless user
          raise ActionController::RoutingError, "Missing user: #{params[:nickname]}" if private_user?
          raise ActionController::RoutingError, "Blocked User" if user.blocked? && !current_user&.admin?
        end

        private

        def private_user?
          user.published_at.nil?
        end

        def user
          return unless params[:nickname]

          @user ||= current_organization.users.entire_collection.find_by("LOWER(nickname) = ?", params[:nickname].downcase)
        end
      end
    end
  end
end
