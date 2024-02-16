# frozen_string_literal: true

module Decidim
  module Privacy
    module OrderReminderGeneratorExtensions
      extend ActiveSupport::Concern

      included do
        private

        # Overridden in order to include all users, not only published accounts.
        def send_reminders(component)
          budgets = Decidim::Budgets::Budget.where(component: component)
          pending_orders = Decidim::Budgets::Order.where(budget: budgets, checked_out_at: nil)
          users = Decidim::User.entire_collection.where(id: pending_orders.pluck(:decidim_user_id).uniq)
          users.each do |user|
            reminder = Decidim::Reminder.find_or_create_by(user: user, component: component)
            users_pending_orders = pending_orders.where(user: user)
            update_reminder_records(reminder, users_pending_orders)
            if reminder.records.active.any?
              Decidim::Budgets::SendVoteReminderJob.perform_later(reminder)
              @reminder_jobs_queued += 1
            end
          end
        end
      end
    end
  end
end
