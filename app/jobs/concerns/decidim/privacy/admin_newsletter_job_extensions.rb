# frozen_string_literal: true

module Decidim
  module Privacy
    module AdminNewsletterJobExtensions
      extend ActiveSupport::Concern

      included do
        private

        def recipients
          @recipients ||= Decidim::User.entire_collection
                                       .where(organization: @newsletter.organization)
                                       .where(id: @recipients_ids)
        end
      end
    end
  end
end
