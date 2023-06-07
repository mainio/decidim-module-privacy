# frozen_string_literal: true

module Decidim
  module Privacy
    module ImpersonationsControllerExtensions
      extend ActiveSupport::Concern

      included do
        private

        def user
          @user ||= if creating_managed_user?
                      existing_managed_user || new_managed_user
                    else
                      current_organization.users.entire_collection.find(params[:impersonatable_user_id])
                    end
        end
      end
    end
  end
end
