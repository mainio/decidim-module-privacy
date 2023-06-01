# frozen_string_literal: true

module Decidim
  module Privacy
    module ActivityCellExtensions
      extend ActiveSupport::Concern

      included do
        def author
          return unless show_author? && user.is_a?(UserBaseEntity)

          presenter = case user
                      when Decidim::User
                        return unless user.public?

                        UserPresenter.new(user)
                      when Decidim::UserGroup
                        UserGroupPresenter.new(user)
                      end

          return unless presenter

          cell "decidim/author", presenter
        end
      end
    end
  end
end
