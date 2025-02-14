# frozen_string_literal: true

module Decidim
  module Privacy
    module BlockUserFormExtensions
      extend ActiveSupport::Concern
      included do
        def user
          @user ||= Decidim::UserBaseEntity.entire_collection.find_by(
            id: user_id,
            organization: current_organization
          )
        end
      end
    end
  end
end
