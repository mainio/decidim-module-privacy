# frozen_string_literal: true

module Decidim
  module Privacy
    module InviteUserExtensions
      extend ActiveSupport::Concern

      included do
        private

        def user
          @user ||= Decidim::User.entire_collection.where(organization: form.organization).where(email: form.email.downcase).first
        end
      end
    end
  end
end
