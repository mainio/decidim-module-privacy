# frozen_string_literal: true

module Decidim
  module Privacy
    module ProposalsControllerExtensions
      extend ActiveSupport::Concern

      include Decidim::Privacy::PrivacyActionsExtensions

      private

      def public_actions
        [:create, :edit, :amend]
      end
    end
  end
end
