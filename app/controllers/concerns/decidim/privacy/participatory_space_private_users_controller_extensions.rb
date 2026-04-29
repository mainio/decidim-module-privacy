# frozen_string_literal: true

module Decidim
  module Privacy
    module ParticipatorySpacePrivateUsersControllerExtensions
      extend ActiveSupport::Concern
      included do
        def index
          unless members.none?
            enforce_permission_to :list, :members
            redirect_to decidim_assemblies.assembly_path(current_participatory_space) unless current_user_can_visit_space?
          end
        end

        private

        def members
          @members ||= current_participatory_space
                       .participatory_space_private_users
                       .published
                       .filter { |item| item.user.is_a?(::Decidim::User) && item.user.published_at.present? }
        end
      end
    end
  end
end
