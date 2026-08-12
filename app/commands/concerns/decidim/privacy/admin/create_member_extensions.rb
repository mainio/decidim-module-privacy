# frozen_string_literal: true

module Decidim
  module Privacy
    module Admin
      module CreateMemberExtensions
        extend ActiveSupport::Concern

        included do
          private

          def existing_user
            return @existing_user if defined?(@existing_user)

            @existing_user = Decidim::User.entire_collection.find_by(
              email: form.email.downcase,
              organization: member_to.organization
            )
          end
        end
      end
    end
  end
end
