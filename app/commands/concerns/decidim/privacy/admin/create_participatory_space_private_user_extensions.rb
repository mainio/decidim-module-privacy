# frozen_string_literal: true

module Decidim
  module Privacy
    module Admin
      module CreateParticipatorySpacePrivateUserExtensions
        extend ActiveSupport::Concern

        included do
          private

          def existing_user
            return @existing_user if defined?(@existing_user)

            @existing_user = Decidim::User.entire_collection.find_by(
              email: form.email.downcase,
              organization: private_user_to.organization
            )

            InviteUserAgain.call(@existing_user, invitation_instructions) if @existing_user&.invitation_pending?
            @existing_user
          end
        end
      end
    end
  end
end
