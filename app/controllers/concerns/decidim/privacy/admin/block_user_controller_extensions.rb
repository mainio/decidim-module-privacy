# frozen_string_literal: true

module Decidim
  module Privacy
    module Admin
      module BlockUserControllerExtensions
        extend ActiveSupport::Concern
        included do
          private

          def user
            @user ||= Decidim::UserBaseEntity.entire_collection.find_by(
              id: params[:user_id],
              organization: current_organization
            )
          end
        end
      end
    end
  end
end
