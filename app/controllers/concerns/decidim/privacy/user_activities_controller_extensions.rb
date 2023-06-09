# frozen_string_literal: true

module Decidim
  module Privacy
    module UserActivitiesControllerExtensions
      extend ActiveSupport::Concern

      included do
        def index
          if private_user?
            render "decidim/privacy/private_account"
          else
            raise ActionController::RoutingError, "Missing user: #{params[:nickname]}" unless user
            raise ActionController::RoutingError, "Blocked User" if user.blocked? && !current_user&.admin?
          end
        end

        def private_user?
          return unless params[:nickname]

          Decidim::User.entire_collection.find_by(nickname: params[:nickname]).published_at.nil?
        end
      end
    end
  end
end
