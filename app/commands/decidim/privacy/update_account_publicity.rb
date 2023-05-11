# frozen_string_literal: true

module Decidim
  module Privacy
    class UpdateAccountPublicity < Decidim::Command
      def initialize(user, form)
        @user = user
        @form = form
      end

      def call
        return broadcast(:invalid) unless @form.valid?

        update_user_account

        broadcast(:ok, @user)
      end

      private

      def update_user_account
        @user.update!(published_at: Time.current)
      end
    end
  end
end
