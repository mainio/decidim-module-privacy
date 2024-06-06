# frozen_string_literal: true

module Decidim
  module Privacy
    module ProfileActionsCellExtensions
      extend ActiveSupport::Concern

      included do
        def can_join_user_group?
          return false unless user_group?
          return false unless current_user
          return false unless current_user.public?

          !Decidim::UserGroupMembership.exists?(user: current_user, user_group: model)
        end
      end
    end
  end
end
