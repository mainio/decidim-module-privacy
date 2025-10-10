# frozen_string_literal: true

module Decidim
  module Privacy
    module AdminLog
      module UserModerationPresenterExtensions
        extend ActiveSupport::Concern

        included do
          def unreported_user
            @unreported_user ||= Decidim::UserBaseEntity.entire_collection.find_by(id: action_log.extra.dig("extra", "user_id"))
          end
        end
      end
    end
  end
end
