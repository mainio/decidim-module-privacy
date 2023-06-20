# frozen_string_literal: true

module Decidim
  module Privacy
    module CreateOmniauthRegistrationExtensions
      extend ActiveSupport::Concern

      included do
        # we need to ananymize the user nickname to safegaurd users' name leakage
        # through nicknames. We are using letter 'u' followed by the id of the user.
        # We need to update this field after the user has been generated to access the
        # user id, in case the user is registering.
        def call
          verify_oauth_signature!

          begin
            if existing_identity
              user = existing_identity.user
              verify_user_confirmed(user)

              return broadcast(:ok, user)
            end
            return broadcast(:invalid) if form.invalid?

            transaction do
              create_or_find_user
              ananymize_user_nickname
              @identity = create_identity
            end
            trigger_omniauth_registration

            broadcast(:ok, @user)
          rescue ActiveRecord::RecordInvalid => e
            broadcast(:error, e.record)
          end
        end

        def existing_identity
          @existing_identity ||= Identity.find_by(
            user: organization.users.entire_collection,
            provider: form.provider,
            uid: form.uid
          )
        end

        private

        def ananymize_user_nickname
          @user.update!(nickname: "u_#{@user.id}")
        end
      end
    end
  end
end
