# frozen_string_literal: true

module Decidim
  module Privacy
    module GroupsControllerExtensions
      extend ActiveSupport::Concern

      included do
        def create
          enforce_permission_to :create, :user_group, current_user: current_user
          @form = form(UserGroupForm).from_params(params)

          CreateUserGroup.call(@form) do
            on(:ok) do
              flash[:notice] = t("groups.create.email_confirmation", scope: "decidim.privacy")

              redirect_to profile_path(current_user.nickname)
            end

            on(:invalid) do
              flash[:alert] = t("groups.create.error", scope: "decidim")
              render action: :new
            end
          end
        end
      end
    end
  end
end
