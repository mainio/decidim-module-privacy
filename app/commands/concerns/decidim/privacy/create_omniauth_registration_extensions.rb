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
              anonymize_user_nickname
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

        def anonymize_user_nickname
          @user.update!(nickname: "u_#{@user.id}")
        end

        def create_or_find_user
          @user = User.entire_collection.find_or_initialize_by(
            email: verified_email,
            organization: organization
          )

          if @user.persisted?
            # If user has left the account unconfirmed and later on decides to sign
            # in with omniauth with an already verified account, the account needs
            # to be marked confirmed.
            @user.skip_confirmation! if !@user.confirmed? && @user.email == verified_email
          else
            generated_password = SecureRandom.hex

            @user.email = (verified_email || form.email)
            @user.name = form.name
            @user.nickname = form.normalized_nickname
            @user.newsletter_notifications_at = nil
            @user.password = generated_password
            @user.password_confirmation = generated_password
            if form.avatar_url.present?
              url = URI.parse(form.avatar_url)
              filename = File.basename(url.path)
              file = url.open
              @user.avatar.attach(io: file, filename: filename)
            end
            @user.skip_confirmation! if verified_email
          end

          @user.tos_agreement = "1"
          @user.save!
        end
      end
    end
  end
end
