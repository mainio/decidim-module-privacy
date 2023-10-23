# frozen_string_literal: true

# The following changes are related to "Ask old password for changing email/password(PR #11737)"
# These changes should be removed once it has been backported to v.27
module Decidim
  module Privacy
    module AccountControllerExtensions
      extend ActiveSupport::Concern
      included do
        def show
          enforce_permission_to(:show, :user, current_user: current_user)
          @account = form(AccountForm).from_model(current_user)
          @account.password = nil
        end

        def update
          enforce_permission_to(:update, :user, current_user: current_user)
          @account = form(AccountForm).from_params(account_params)
          UpdateAccount.call(current_user, @account) do
            on(:ok) do |email_is_unconfirmed|
              flash[:notice] = if email_is_unconfirmed
                                 t("account.update.success_with_email_confirmation", scope: "decidim")
                               else
                                 t("account.update.success", scope: "decidim")
                               end

              bypass_sign_in(current_user)
              redirect_to account_path(locale: current_user.reload.locale)
            end

            on(:invalid) do |password|
              fetch_entered_password(password)
              flash[:alert] = t("account.update.error", scope: "decidim")
              render action: :show
            end
          end
        end

        private

        def fetch_entered_password(password)
          @account.password = password
        end
      end
    end
  end
end
