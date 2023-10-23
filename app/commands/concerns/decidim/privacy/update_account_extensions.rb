# frozen_string_literal: true

# The following changes are related to "Ask old password for changing email/password(PR #11737)"
# These changes should be removed once it has been backported to v.27
module Decidim
  module Privacy
    module UpdateAccountExtensions
      extend ActiveSupport::Concern

      included do
        def call
          return broadcast(:invalid, @form.password) unless @form.valid?

          update_personal_data
          update_avatar
          update_password

          if @user.valid?
            @user.save!
            notify_followers
            broadcast(:ok, @user.unconfirmed_email.present?)
          else
            [:avatar, :password].each do |key|
              @form.errors.add key, @user.errors[key] if @user.errors.has_key? key
            end
            broadcast(:invalid, @form.password)
          end
        end
      end
    end
  end
end
