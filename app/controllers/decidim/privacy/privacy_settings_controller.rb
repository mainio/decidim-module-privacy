# frozen_string_literal: true

module Decidim
  module Privacy
    class PrivacySettingsController < ::Decidim::ApplicationController
      include Decidim::UserProfile

      def show
        enforce_permission_to :read, :user, current_user: current_user
        @privacy_settings = form(::Decidim::Privacy::PrivacySettingsForm).from_model(current_user)
      end

      def update
        enforce_permission_to :read, :user, current_user: current_user
        @privacy_settings = form(::Decidim::Privacy::PrivacySettingsForm).from_params(params)

        UpdatePrivacySettings.call(current_user, @privacy_settings) do
          on(:ok) do
            flash.now[:notice] = t(".success")
          end

          on(:invalid) do
            flash.now[:alert] = t(".error")
          end
        end

        render action: :show
      end
    end
  end
end
