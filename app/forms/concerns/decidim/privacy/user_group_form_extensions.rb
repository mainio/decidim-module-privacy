# frozen_string_literal: true

module Decidim
  module Privacy
    module UserGroupFormExtensions
      extend ActiveSupport::Concern
      included do
        def unique_nickname
          return true if Decidim::UserBaseEntity
                         .entire_collection
                         .where(
                           organization: context.current_organization,
                           nickname: nickname
                         )
                         .where.not(id: id)
                         .empty?

          errors.add :nickname, :taken
          false
        end
      end
    end
  end
end
