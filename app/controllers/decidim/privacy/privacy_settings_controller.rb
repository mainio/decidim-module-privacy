# frozen_string_literal: true

module Decidim
  module Privacy
    class PrivacySettingsController < ::Decidim::ApplicationController
      include Decidim::UserProfile

      def show
        enforce_permission_to :read, :user, current_user: current_user
      end

      def update
        enforce_permission_to :read, :user, current_user: current_user
      end
    end
  end
end
