# frozen_string_literal: true

module Decidim
  module Privacy
    module AdminNewsletterRecipientsExtensions
      extend ActiveSupport::Concern

      included do
        def query
          recipients = recipients_base_query

          return recipients if @form.send_to_all_users
          return verified_users if @form.send_to_verified_users

          if filters_present?
            filtered_recipients = apply_filters(recipients)
            return recipients.none if filtered_recipients.empty?

            return filtered_recipients
          end

          recipients
        end

        private

        def recipients_base_query
          Decidim::User
            .entire_collection
            .available
            .where(organization: @form.current_organization)
            .where.not(newsletter_notifications_at: nil)
            .where.not(email: nil)
            .where.not(confirmed_at: nil)
            .not_deleted
        end
      end
    end
  end
end
