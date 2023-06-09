# frozen_string_literal: true

module Decidim
  module Privacy
    module AccountFormExtensions
      extend ActiveSupport::Concern

      included do
        def unique_email
          return true if Decidim::UserBaseEntity.entire_collection.where(
            organization: context.current_organization,
            email: email
          ).where.not(id: context.current_user.id).empty?

          errors.add :email, :taken
          false
        end

        def unique_nickname
          return true if Decidim::UserBaseEntity.entire_collection.where(
            "decidim_organization_id = ? AND LOWER(nickname) = ? ",
            context.current_organization.id,
            nickname.downcase
          ).where.not(id: context.current_user.id).empty?

          errors.add :nickname, :taken
          false
        end
      end
    end
  end
end
