# frozen_string_literal: true

# The following changes are related to "Ask old password for changing email/password(PR #11737)"
# These changes should be removed once it has been backported to v.27
module Decidim
  module PasswordsHelper
    def password_field_options_for(user)
      user =
        case user
        when :user
          Decidim::User.new
        when :admin
          Decidim::User.new(admin: true)
        when String
          Decidim::User.with_reset_password_token(user)
        else
          user
        end
      min_length = ::PasswordValidator.minimum_length_for(user)
      help_text =
        if needs_admin_password?(user)
          t("devise.passwords.edit.password_help_admin", minimun_characters: min_length)
        else
          t("devise.passwords.edit.password_help", minimun_characters: min_length)
        end

      {
        autocomplete: "new-password",
        required: true,
        label: false,
        help_text: help_text,
        value: @account&.password,
        minlength: min_length,
        maxlength: ::PasswordValidator::MAX_LENGTH,
        placeholder: "••••••"
      }
    end

    def old_password_options
      help_text = t("devise.passwords.edit.old_password_help")

      {
        autocomplete: "current-password",
        required: true,
        label: false,
        help_text: help_text,
        placeholder: "••••••"
      }
    end

    def needs_admin_password?(user)
      return false unless user&.admin?
      return false unless Decidim.config.admin_password_strong

      true
    end
  end
end
