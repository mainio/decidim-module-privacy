# frozen_string_literal: true

module Decidim
  module Privacy
    module ImpersonationLogsControllerExtensions
      extend ActiveSupport::Concern

      included do
        private

        def user
          @user ||= current_organization.users.entire_collection.find(params[:impersonatable_user_id])
        end
      end
    end
  end
end
