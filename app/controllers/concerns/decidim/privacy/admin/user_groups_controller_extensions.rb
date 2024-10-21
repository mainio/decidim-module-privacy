# frozen_string_literal: true

module Decidim
  module Privacy
    module Admin
      module UserGroupsControllerExtensions
        extend ActiveSupport::Concern
        included do
          def verify
            @user_group = collection.find(params[:id])
            enforce_permission_to :verify, :user_group, user_group: @user_group
            Decidim::Admin::VerifyUserGroup.call(@user_group, current_user) do
              on(:ok) do
                flash[:notice] = I18n.t("user_group.verify.success", scope: "decidim.admin")
                redirect_back(fallback_location: decidim_admin.user_groups_path)
              end
              on(:invalid) do
                flash[:alert] = I18n.t("user_group.verify.invalid", scope: "decidim.admin")
                redirect_back(fallback_location: decidim_admin.user_groups_path)
              end
              on(:email_confirmation) do
                flash[:alert] = I18n.t("user_group.verify.confirmation_pending", scope: "decidim.admin")
                redirect_back(fallback_location: decidim_admin.user_groups_path)
              end
            end
          end
        end
      end
    end
  end
end
