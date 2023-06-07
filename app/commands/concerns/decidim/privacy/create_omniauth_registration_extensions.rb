# frozen_string_literal: true

module Decidim
  module Privacy
    module CreateOmniauthRegistrationExtensions
      extend ActiveSupport::Concern

      included do
        def existing_identity
          @existing_identity ||= Identity.find_by(
            user: organization.users.entire_collection,
            provider: form.provider,
            uid: form.uid
          )
        end
      end
    end
  end
end
