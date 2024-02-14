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

        # The following changes are related to "Ask old password for changing email/password(PR #11737)"
        # These changes should be removed once it has been backported to v.27
        attribute :old_password
        validate :validate_old_password

        def validate_old_password
          user = context.current_user
          if user.email != email || password.present?
            return true if user.valid_password?(old_password)

            errors.add :old_password, :invalid
            false
          end
        end
      end
    end
  end
end
