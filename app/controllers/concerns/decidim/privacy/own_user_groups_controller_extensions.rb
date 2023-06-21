# frozen_string_literal: true

module Decidim
  module Privacy
    module OwnUserGroupsControllerExtensions
      extend ActiveSupport::Concern

      included do
        def index
          @user_groups = current_user.user_groups.entire_collection
        end
      end
    end
  end
end
