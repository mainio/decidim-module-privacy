# frozen_string_literal: true

module Decidim
  module Privacy
    module MeetingRegistrationInviteFormExtensions
      extend ActiveSupport::Concern

      included do
        def user
          @user ||= current_organization.users.unscoped.find_by(id: user_id)
        end
      end
    end
  end
end
