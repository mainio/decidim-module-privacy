# frozen_string_literal: true

module Decidim
  module Privacy
    class UpdateAnonymity < Decidim::Command
      def initialize(user, form)
        @user = user
        @form = form
      end

      def call
        return broadcast(:invalid) unless @form.valid?

        update_anonymity

        broadcast(:ok, @user)
      end

      private

      def update_anonymity
        @user.update!(anonymity: @form.set_anonymity)
      end
    end
  end
end
