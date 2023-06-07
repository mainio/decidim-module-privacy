# frozen_string_literal: true

module Decidim
  module Privacy
    module HasPrivateUsersExtensions
      extend ActiveSupport::Concern

      included do
        has_many(
          :users,
          -> { entire_collection },
          through: :participatory_space_private_users,
          class_name: "Decidim::User",
          foreign_key: "private_user_to_id"
        )
      end
    end
  end
end
