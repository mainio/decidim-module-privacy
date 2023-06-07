# frozen_string_literal: true

module Decidim
  module Privacy
    module ProfilesControllerExtensions
      extend ActiveSupport::Concern

      included do
        before_action :add_nofollow_meta_tag

        def show
          return redirect_to profile_timeline_path(nickname: params[:nickname]) if profile_holder == current_user
          return redirect_to profile_members_path if profile_holder.is_a?(Decidim::UserGroup)
          raise ActionController::RoutingError, "Not Found" if profile_holder.published_at.nil?

          redirect_to profile_activity_path(nickname: params[:nickname])
        end

        private

        def add_nofollow_meta_tag
          snippets.add(:head, "<meta name=\"robots\" content=\"noindex, nofollow\">")
        end
      end
    end
  end
end
