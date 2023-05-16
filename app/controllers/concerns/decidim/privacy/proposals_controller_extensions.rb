# frozen_string_literal: true

module Decidim
  module Privacy
    module ProposalsControllerExtensions
      extend ActiveSupport::Concern
      include Decidim::Privacy::PrivacyHelper

      included do
        before_action :ensure_public_account, only: [:new, :create, :complete]
      end
    end
  end
end
